import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const NVIDIA_BASE_URL = "https://integrate.api.nvidia.com/v1";
const MODEL = "meta/llama-3.1-70b-instruct";

const SYSTEM_PROMPT = `You are a clinical dermatology teaching assistant for Epidexa. 
Your goal is to provide brief, high-yield clinical pearls for medical trainees.
- Be concise. Avoid long-winded introductions or redundant information.
- Use the provided visual cue descriptions to explain diagnostic reasoning.
- IMPORTANT: If the user hasn't submitted a diagnosis yet (or is still in the middle of a case), do NOT imply they were "wrong". Instead, focus on guiding their clinical reasoning based on the observations they've made so far.
- If they have finished a case, explain the "why" behind the correct diagnosis concisely.
Always clarify that this is for educational purposes only.`;

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, content-type",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
      },
    });
  }

  try {
    const { messages, caseContext, pageContext } = await req.json();

    if (!messages || !Array.isArray(messages)) {
      return new Response(JSON.stringify({ error: "messages array required" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const apiKey = Deno.env.get("NVIDIA_API_KEY");
    if (!apiKey) {
      return new Response(JSON.stringify({ error: "API key not configured" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Build system message
    let systemContent = SYSTEM_PROMPT;
    if (pageContext) {
      systemContent += `\n\nThe user is currently ${pageContext}.`;
    }
    if (caseContext) {
      const diagStatus = caseContext.diagnosisCorrect === null ? "not yet submitted" : (caseContext.diagnosisCorrect ? "correct" : "incorrect");
      const nextStepStatus = caseContext.nextStepCorrect === null ? "not yet submitted" : (caseContext.nextStepCorrect ? "correct" : "incorrect");
      
      systemContent += `\n\nThe user is currently working on or has completed a clinical case:\n` +
        `Case: ${caseContext.title}\n` +
        `Patient Presentation: ${caseContext.patientPresentation}\n` +
        `Additional History: ${caseContext.additionalHistory ?? "none provided"}\n` +
        `Correct diagnosis: ${caseContext.correctDiagnosis}\n` +
        `User's current diagnosis choice: ${caseContext.userDiagnosis ?? "none yet"}\n` +
        `Diagnosis result: ${diagStatus}\n` +
        `Next step result: ${nextStepStatus}\n` +
        `Key visual cues: ${caseContext.keyVisualCues?.join(", ") ?? "none"}\n\n` +
        `IMPORTANT: Pay close attention to the patient's demographics, occupation, and history provided above when explaining the clinical reasoning. If the results are "not yet submitted", do NOT tell the user they are wrong. Help them explore the visual cues instead.`;
    }

    const response = await fetch(`${NVIDIA_BASE_URL}/chat/completions`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: MODEL,
        messages: [
          { role: "system", content: systemContent },
          ...messages,
        ],
        max_tokens: 512,
        temperature: 0.4,
      }),
    });

    if (!response.ok) {
      const err = await response.text();
      return new Response(JSON.stringify({ error: err }), {
        status: response.status,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      });
    }

    const data = await response.json();
    const reply = data.choices?.[0]?.message?.content ?? "";

    return new Response(JSON.stringify({ reply }), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
    });
  }
});
