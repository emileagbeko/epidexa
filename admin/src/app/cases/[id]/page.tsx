"use client";

import { useEffect, useRef, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { supabase } from "@/lib/supabase";
import {
  ChevronLeft,
  Plus,
  Trash2,
  Upload,
  ImageIcon,
  Save,
  Loader2,
  Library,
} from "lucide-react";

interface ObsOption { id: string; label: string; isCorrect: boolean; }
interface DiagOption { id: string; label: string; isCorrect: boolean; }
interface NextOption { id: string; label: string; isCorrect: boolean; rationale: string; }
interface FeedbackData {
  correctDiagnosis: string;
  explanation: string;
  keyVisualCues: string[];
  differentialNote: string;
}

const DIFFICULTIES = ["beginner", "intermediate", "advanced"];
const CATEGORIES = ["inflammatory", "fungal", "bacterial", "viral", "neoplastic", "autoimmune"];
const STATUSES = ["Draft", "Published"];

const FITZPATRICK_TYPES = [
  { value: "I",   label: "I – Very fair",  bg: "bg-amber-50",      text: "text-amber-700",  dot: "#fef3c7" },
  { value: "II",  label: "II – Fair",       bg: "bg-amber-100",     text: "text-amber-800",  dot: "#fde68a" },
  { value: "III", label: "III – Medium",    bg: "bg-orange-100",    text: "text-orange-800", dot: "#fed7aa" },
  { value: "IV",  label: "IV – Olive",      bg: "bg-orange-200",    text: "text-orange-900", dot: "#fdba74" },
  { value: "V",   label: "V – Brown",       bg: "bg-orange-900/20", text: "text-orange-950", dot: "#92400e" },
  { value: "VI",  label: "VI – Dark",       bg: "bg-gray-800",      text: "text-gray-100",   dot: "#1f2937" },
];

function FitzpatrickBadge({ type }: { type: string }) {
  const f = FITZPATRICK_TYPES.find((t) => t.value === type);
  if (!f) return null;
  return (
    <span className={`inline-flex items-center gap-1 text-[10px] font-bold px-2 py-0.5 rounded-full uppercase tracking-wide ${f.bg} ${f.text}`}>
      <span className="w-2 h-2 rounded-full inline-block shrink-0" style={{ background: f.dot }} />
      {f.label}
    </span>
  );
}

function uid() {
  return Math.random().toString(36).slice(2, 9);
}

export default function CaseEditPage() {
  const params = useParams();
  const router = useRouter();
  const caseId = params.id as string;
  const isNew = caseId === "new";

  const [loading, setLoading] = useState(!isNew);
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState("");

  // Basic info
  const [title, setTitle] = useState("");
  const [difficulty, setDifficulty] = useState("beginner");
  const [category, setCategory] = useState("inflammatory");
  const [status, setStatus] = useState("Draft");

  // Patient info
  const [patientPresentation, setPatientPresentation] = useState("");
  const [additionalHistory, setAdditionalHistory] = useState("");

  // Image
  const [imagePath, setImagePath] = useState<string | null>(null);
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [visualDescription, setVisualDescription] = useState("");
  const [imageTab, setImageTab] = useState<"upload" | "library">("upload");
  const [fitzpatrickType, setFitzpatrickType] = useState("");
  const [imageBankId, setImageBankId] = useState<string | null>(null);
  const [libraryImages, setLibraryImages] = useState<any[]>([]);
  const [libraryLoaded, setLibraryLoaded] = useState(false);
  const [libraryLoading, setLibraryLoading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Question options
  const [observationOptions, setObservationOptions] = useState<ObsOption[]>([]);
  const [diagnosisOptions, setDiagnosisOptions] = useState<DiagOption[]>([
    { id: uid(), label: "", isCorrect: true },
    { id: uid(), label: "", isCorrect: false },
    { id: uid(), label: "", isCorrect: false },
    { id: uid(), label: "", isCorrect: false },
  ]);
  const [nextStepOptions, setNextStepOptions] = useState<NextOption[]>([]);

  // Feedback
  const [feedback, setFeedback] = useState<FeedbackData>({
    correctDiagnosis: "",
    explanation: "",
    keyVisualCues: [],
    differentialNote: "",
  });
  const [cueInput, setCueInput] = useState("");

  // Tags
  const [conceptTags, setConceptTags] = useState<string[]>([]);
  const [tagInput, setTagInput] = useState("");
  const [specialtyNote, setSpecialtyNote] = useState("");

  useEffect(() => {
    if (!isNew) loadCase();
  }, [caseId]);

  async function loadCase() {
    setLoading(true);
    const { data } = await supabase
      .from("clinical_cases")
      .select("*")
      .eq("id", caseId)
      .single();

    if (data) {
      setTitle(data.title ?? "");
      setDifficulty(data.difficulty ?? "beginner");
      setCategory(data.category ?? "inflammatory");
      setStatus(data.status ?? "Draft");
      setPatientPresentation(data.patient_presentation ?? "");
      setAdditionalHistory(data.additional_history ?? "");
      setImagePath(data.image_path ?? null);
      setVisualDescription(data.visual_description ?? "");
      setFitzpatrickType(data.fitzpatrick_type ?? "");
      setImageBankId(data.image_bank_id ?? null);
      setObservationOptions(data.observation_options ?? []);
      setDiagnosisOptions(
        data.diagnosis_options?.length
          ? data.diagnosis_options
          : [
              { id: uid(), label: "", isCorrect: true },
              { id: uid(), label: "", isCorrect: false },
              { id: uid(), label: "", isCorrect: false },
              { id: uid(), label: "", isCorrect: false },
            ]
      );
      setNextStepOptions(data.next_step_options ?? []);
      setFeedback(
        data.feedback ?? { correctDiagnosis: "", explanation: "", keyVisualCues: [], differentialNote: "" }
      );
      setConceptTags(data.concept_tags ?? []);
      setSpecialtyNote(data.specialty_note ?? "");
    }
    setLoading(false);
  }

  async function loadLibraryImages() {
    if (libraryLoaded) return;
    setLibraryLoading(true);
    const { data } = await supabase
      .from("clinical_images")
      .select("id, image_url, condition, fitzpatrick, description")
      .order("condition");
    setLibraryImages(data ?? []);
    setLibraryLoaded(true);
    setLibraryLoading(false);
  }

  function switchToLibrary() {
    setImageTab("library");
    loadLibraryImages();
  }

  function selectFromLibrary(img: any) {
    setImagePath(img.image_url);
    setImagePreview(null);
    setImageFile(null);
    setImageBankId(img.id);
    setFitzpatrickType(img.fitzpatrick);
  }

  function clearImage() {
    setImagePath(null);
    setImagePreview(null);
    setImageFile(null);
    setImageBankId(null);
    setFitzpatrickType("");
  }

  function handleImageFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setImageFile(file);
    setImagePreview(URL.createObjectURL(file));
    setImageBankId(null);
  }

  // Observation helpers
  function addObservation() {
    setObservationOptions((prev) => [...prev, { id: uid(), label: "", isCorrect: false }]);
  }
  function removeObservation(id: string) {
    setObservationOptions((prev) => prev.filter((o) => o.id !== id));
  }
  function updateObservation(id: string, field: keyof ObsOption, value: any) {
    setObservationOptions((prev) =>
      prev.map((o) => (o.id === id ? { ...o, [field]: value } : o))
    );
  }

  // Diagnosis helpers
  function setCorrectDiagnosis(id: string) {
    setDiagnosisOptions((prev) => prev.map((d) => ({ ...d, isCorrect: d.id === id })));
  }
  function updateDiagnosisLabel(id: string, label: string) {
    setDiagnosisOptions((prev) => prev.map((d) => (d.id === id ? { ...d, label } : d)));
  }
  function addDiagnosisOption() {
    setDiagnosisOptions((prev) => [...prev, { id: uid(), label: "", isCorrect: false }]);
  }
  function removeDiagnosisOption(id: string) {
    setDiagnosisOptions((prev) => {
      const next = prev.filter((d) => d.id !== id);
      if (!next.some((d) => d.isCorrect) && next.length > 0) next[0].isCorrect = true;
      return next;
    });
  }

  // Next step helpers
  function addNextStep() {
    setNextStepOptions((prev) => [...prev, { id: uid(), label: "", isCorrect: false, rationale: "" }]);
  }
  function removeNextStep(id: string) {
    setNextStepOptions((prev) => prev.filter((n) => n.id !== id));
  }
  function updateNextStep(id: string, field: keyof NextOption, value: any) {
    setNextStepOptions((prev) => prev.map((n) => (n.id === id ? { ...n, [field]: value } : n)));
  }

  // Tag helpers
  function addTag(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "Enter" && tagInput.trim()) {
      e.preventDefault();
      const tag = tagInput.trim().toLowerCase().replace(/\s+/g, "-");
      if (!conceptTags.includes(tag)) setConceptTags((prev) => [...prev, tag]);
      setTagInput("");
    }
  }
  function removeTag(tag: string) {
    setConceptTags((prev) => prev.filter((t) => t !== tag));
  }

  // Key visual cue helpers
  function addCue(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === "Enter" && cueInput.trim()) {
      e.preventDefault();
      if (!feedback.keyVisualCues.includes(cueInput.trim())) {
        setFeedback((prev) => ({ ...prev, keyVisualCues: [...prev.keyVisualCues, cueInput.trim()] }));
      }
      setCueInput("");
    }
  }
  function removeCue(cue: string) {
    setFeedback((prev) => ({ ...prev, keyVisualCues: prev.keyVisualCues.filter((c) => c !== cue) }));
  }

  async function handleSave() {
    if (!title.trim()) { setSaveError("Case title is required."); return; }
    if (!patientPresentation.trim()) { setSaveError("Patient presentation is required."); return; }
    setSaveError("");
    setSaving(true);

    let finalImagePath = imagePath;

    if (imageFile) {
      const ext = imageFile.name.split(".").pop();
      const fileName = `${isNew ? `new_${Date.now()}` : caseId}.${ext}`;
      const { data: uploadData, error: uploadError } = await supabase.storage
        .from("case-images")
        .upload(fileName, imageFile, { upsert: true });

      if (!uploadError && uploadData) {
        const { data: { publicUrl } } = supabase.storage
          .from("case-images")
          .getPublicUrl(uploadData.path);
        finalImagePath = publicUrl;
      }
    }

    const newId = isNew ? `case_${Date.now()}` : caseId;

    const { error } = await supabase.from("clinical_cases").upsert({
      id: newId,
      title: title.trim(),
      difficulty,
      category,
      status,
      patient_presentation: patientPresentation.trim(),
      additional_history: additionalHistory.trim() || null,
      image_path: finalImagePath,
      visual_description: visualDescription.trim() || null,
      fitzpatrick_type: fitzpatrickType || null,
      image_bank_id: imageBankId || null,
      observation_options: observationOptions,
      diagnosis_options: diagnosisOptions,
      next_step_options: nextStepOptions,
      feedback,
      concept_tags: conceptTags,
      specialty_note: specialtyNote.trim() || null,
    });

    setSaving(false);
    if (error) {
      setSaveError(error.message);
    } else {
      router.push("/cases");
    }
  }

  const isFlutterAsset = imagePath?.startsWith("assets/");
  const isStorageUrl = imagePath?.startsWith("https://");
  const hasImage = imagePreview || isStorageUrl || isFlutterAsset;

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="animate-spin text-primary" size={32} />
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto space-y-8 pb-16">
      {/* Header */}
      <div className="flex items-center gap-4">
        <button onClick={() => router.push("/cases")} className="text-gray-400 hover:text-gray-700 transition-colors">
          <ChevronLeft size={24} />
        </button>
        <div className="flex-1">
          <h1 className="text-2xl font-bold text-gray-900">
            {isNew ? "New Clinical Case" : `Edit: ${title || caseId}`}
          </h1>
          {!isNew && <p className="text-xs text-gray-400 mt-0.5">{caseId}</p>}
        </div>
        <button
          onClick={handleSave}
          disabled={saving}
          className="bg-primary text-white px-5 py-2 rounded-lg flex items-center gap-2 font-medium hover:bg-opacity-90 transition-all disabled:opacity-60"
        >
          {saving ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />}
          {saving ? "Saving…" : "Save Case"}
        </button>
      </div>

      {saveError && (
        <div className="bg-red-50 border border-red-200 text-red-700 text-sm px-4 py-3 rounded-lg">
          {saveError}
        </div>
      )}

      {/* 1. Basic Info */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={1} title="Basic Info" />
        <div>
          <label className="field-label">Case Title</label>
          <input value={title} onChange={(e) => setTitle(e.target.value)} className="field-input" placeholder="e.g. Itchy rash on forearm" />
        </div>
        <div className="grid grid-cols-3 gap-4">
          <div>
            <label className="field-label">Difficulty</label>
            <select value={difficulty} onChange={(e) => setDifficulty(e.target.value)} className="field-input">
              {DIFFICULTIES.map((d) => <option key={d} value={d}>{d.charAt(0).toUpperCase() + d.slice(1)}</option>)}
            </select>
          </div>
          <div>
            <label className="field-label">Category</label>
            <select value={category} onChange={(e) => setCategory(e.target.value)} className="field-input">
              {CATEGORIES.map((c) => <option key={c} value={c}>{c.charAt(0).toUpperCase() + c.slice(1)}</option>)}
            </select>
          </div>
          <div>
            <label className="field-label">Status</label>
            <select value={status} onChange={(e) => setStatus(e.target.value)} className="field-input">
              {STATUSES.map((s) => <option key={s} value={s}>{s}</option>)}
            </select>
          </div>
        </div>
      </section>

      {/* 2. Patient Info */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={2} title="Patient Presentation" />
        <div>
          <label className="field-label">Clinical Scenario</label>
          <textarea value={patientPresentation} onChange={(e) => setPatientPresentation(e.target.value)} className="field-input h-28 resize-none" placeholder="Describe the patient scenario as shown to students…" />
        </div>
        <div>
          <label className="field-label">Additional History <span className="text-gray-400 font-normal">(optional)</span></label>
          <textarea value={additionalHistory} onChange={(e) => setAdditionalHistory(e.target.value)} className="field-input h-20 resize-none" placeholder="Drug history, allergies, family history…" />
        </div>
      </section>

      {/* 3. Clinical Image */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={3} title="Clinical Image" />

        {/* Tab switcher */}
        <div className="flex gap-1 bg-gray-100 rounded-lg p-1 w-fit">
          <button
            onClick={() => setImageTab("upload")}
            className={`px-4 py-1.5 rounded-md text-sm font-medium transition-all ${
              imageTab === "upload" ? "bg-white text-gray-900 shadow-sm" : "text-gray-500 hover:text-gray-700"
            }`}
          >
            Upload
          </button>
          <button
            onClick={switchToLibrary}
            className={`px-4 py-1.5 rounded-md text-sm font-medium transition-all flex items-center gap-1.5 ${
              imageTab === "library" ? "bg-white text-gray-900 shadow-sm" : "text-gray-500 hover:text-gray-700"
            }`}
          >
            <Library size={13} />
            Pick from Library
          </button>
        </div>

        {imageTab === "upload" ? (
          <div className="space-y-4">
            {/* Current image preview */}
            {hasImage && (
              <div className="rounded-xl overflow-hidden bg-gray-50 border border-gray-100">
                {imagePreview ? (
                  <img src={imagePreview} alt="Preview" className="w-full max-h-64 object-contain" />
                ) : isStorageUrl ? (
                  <img src={imagePath!} alt="Case image" className="w-full max-h-64 object-contain" />
                ) : isFlutterAsset ? (
                  <div className="flex items-center gap-3 p-4 text-sm text-gray-500">
                    <ImageIcon size={20} className="text-gray-400" />
                    <div>
                      <p className="font-medium text-gray-700">Flutter app asset</p>
                      <p className="text-xs font-mono">{imagePath}</p>
                      <p className="text-xs mt-1">Upload a new image below to replace it with a hosted version.</p>
                    </div>
                  </div>
                ) : null}
              </div>
            )}

            <div
              onClick={() => fileInputRef.current?.click()}
              className="border-2 border-dashed border-gray-200 rounded-xl p-8 text-center hover:border-primary transition-colors cursor-pointer"
            >
              <Upload className="mx-auto text-gray-400 mb-2" size={22} />
              <p className="text-sm font-medium text-gray-600">{imagePath ? "Replace image" : "Upload clinical image"}</p>
              <p className="text-xs text-gray-400 mt-1">PNG, JPG up to 5MB</p>
              <input ref={fileInputRef} type="file" accept="image/*" className="hidden" onChange={handleImageFileChange} />
            </div>

            {imagePath && !imageFile && (
              <button onClick={clearImage} className="text-xs text-red-500 hover:text-red-700 transition-colors">
                Remove image (make text-only)
              </button>
            )}
          </div>
        ) : (
          <div className="space-y-3">
            {libraryLoading ? (
              <div className="flex items-center justify-center h-32">
                <Loader2 className="animate-spin text-primary" size={24} />
              </div>
            ) : libraryImages.length === 0 ? (
              <div className="p-8 text-center text-gray-400 text-sm border-2 border-dashed border-gray-200 rounded-xl">
                No images in the library yet.{" "}
                <button onClick={() => router.push("/media")} className="text-primary underline">
                  Add some in Image Bank
                </button>
              </div>
            ) : (
              <div className="grid grid-cols-3 gap-3 max-h-80 overflow-y-auto pr-1">
                {libraryImages.map((img) => (
                  <div
                    key={img.id}
                    onClick={() => selectFromLibrary(img)}
                    className={`cursor-pointer rounded-xl overflow-hidden border-2 transition-all ${
                      imageBankId === img.id
                        ? "border-primary ring-2 ring-primary/20"
                        : "border-transparent hover:border-gray-300"
                    }`}
                  >
                    <div className="aspect-square bg-gray-100">
                      <img src={img.image_url} alt={img.condition} className="w-full h-full object-cover" />
                    </div>
                    <div className="p-2 space-y-1">
                      <p className="text-xs font-medium text-gray-800 truncate">{img.condition}</p>
                      <FitzpatrickBadge type={img.fitzpatrick} />
                    </div>
                  </div>
                ))}
              </div>
            )}
            {imageBankId && imagePath && (
              <button onClick={clearImage} className="text-xs text-red-500 hover:text-red-700 transition-colors">
                Clear selection
              </button>
            )}
          </div>
        )}

        {/* Fitzpatrick tag — shown when any image is set */}
        {(imagePath || imagePreview) && (
          <div className="pt-1 space-y-1.5">
            <label className="field-label">Fitzpatrick Skin Type of this image</label>
            {imageBankId ? (
              <div className="flex items-center gap-2">
                <FitzpatrickBadge type={fitzpatrickType} />
                <span className="text-xs text-gray-400">(auto-filled from library)</span>
              </div>
            ) : (
              <select value={fitzpatrickType} onChange={(e) => setFitzpatrickType(e.target.value)} className="field-input max-w-xs">
                <option value="">Not specified</option>
                {FITZPATRICK_TYPES.map((f) => <option key={f.value} value={f.value}>{f.label}</option>)}
              </select>
            )}
          </div>
        )}

        <div>
          <label className="field-label">Visual Description <span className="text-gray-400 font-normal">(for AI context)</span></label>
          <textarea value={visualDescription} onChange={(e) => setVisualDescription(e.target.value)} className="field-input h-20 resize-none" placeholder="Describe key visual findings for the AI assistant (scale, colour, border, distribution…)" />
        </div>
      </section>

      {/* 4. Observation Options */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={4} title="Observation Options" subtitle="Check all findings that are correct" />
        <div className="space-y-2">
          {observationOptions.map((o) => (
            <div key={o.id} className="flex items-center gap-3">
              <input type="checkbox" checked={o.isCorrect} onChange={(e) => updateObservation(o.id, "isCorrect", e.target.checked)} className="w-4 h-4 accent-primary cursor-pointer" />
              <input value={o.label} onChange={(e) => updateObservation(o.id, "label", e.target.value)} className="flex-1 field-input py-1.5" placeholder="e.g. Erythema (redness)" />
              <button onClick={() => removeObservation(o.id)} className="text-gray-300 hover:text-red-500 transition-colors"><Trash2 size={14} /></button>
            </div>
          ))}
        </div>
        <button onClick={addObservation} className="text-sm text-primary hover:text-primary/80 font-medium flex items-center gap-1">
          <Plus size={14} /> Add observation
        </button>
      </section>

      {/* 5. Diagnosis Options */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={5} title="Diagnosis Options" subtitle="Select the radio button next to the correct diagnosis" />
        <div className="space-y-2">
          {diagnosisOptions.map((d) => (
            <div key={d.id} className="flex items-center gap-3">
              <input type="radio" name="correct-diag" checked={d.isCorrect} onChange={() => setCorrectDiagnosis(d.id)} className="w-4 h-4 accent-primary cursor-pointer" />
              <input value={d.label} onChange={(e) => updateDiagnosisLabel(d.id, e.target.value)} className="flex-1 field-input py-1.5" placeholder="e.g. Irritant contact dermatitis" />
              {diagnosisOptions.length > 2 && (
                <button onClick={() => removeDiagnosisOption(d.id)} className="text-gray-300 hover:text-red-500 transition-colors"><Trash2 size={14} /></button>
              )}
            </div>
          ))}
        </div>
        <button onClick={addDiagnosisOption} className="text-sm text-primary hover:text-primary/80 font-medium flex items-center gap-1">
          <Plus size={14} /> Add option
        </button>
      </section>

      {/* 6. Next Step Options */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={6} title="Next Step Options" subtitle="Check the correct management action" />
        <div className="space-y-3">
          {nextStepOptions.map((n) => (
            <div key={n.id} className="border border-gray-100 rounded-xl p-4 space-y-2">
              <div className="flex items-center gap-3">
                <input type="checkbox" checked={n.isCorrect} onChange={(e) => updateNextStep(n.id, "isCorrect", e.target.checked)} className="w-4 h-4 accent-primary cursor-pointer" />
                <input value={n.label} onChange={(e) => updateNextStep(n.id, "label", e.target.value)} className="flex-1 field-input py-1.5" placeholder="e.g. Prescribe topical corticosteroid" />
                <button onClick={() => removeNextStep(n.id)} className="text-gray-300 hover:text-red-500 transition-colors"><Trash2 size={14} /></button>
              </div>
              <textarea value={n.rationale} onChange={(e) => updateNextStep(n.id, "rationale", e.target.value)} className="field-input h-16 resize-none text-xs" placeholder="Rationale shown to students after selecting this option…" />
            </div>
          ))}
        </div>
        <button onClick={addNextStep} className="text-sm text-primary hover:text-primary/80 font-medium flex items-center gap-1">
          <Plus size={14} /> Add next step
        </button>
      </section>

      {/* 7. Feedback */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={7} title="Feedback & Explanation" subtitle="Shown to students after completing the case" />
        <div>
          <label className="field-label">Correct Diagnosis (display label)</label>
          <input value={feedback.correctDiagnosis} onChange={(e) => setFeedback((f) => ({ ...f, correctDiagnosis: e.target.value }))} className="field-input" placeholder="e.g. Irritant Contact Dermatitis" />
        </div>
        <div>
          <label className="field-label">Explanation</label>
          <textarea value={feedback.explanation} onChange={(e) => setFeedback((f) => ({ ...f, explanation: e.target.value }))} className="field-input h-32 resize-none" placeholder="Full clinical explanation shown after the case…" />
        </div>
        <div>
          <label className="field-label">Key Visual Cues <span className="text-gray-400 font-normal">(press Enter to add)</span></label>
          <div className="flex flex-wrap gap-2 mb-2">
            {feedback.keyVisualCues.map((cue) => (
              <span key={cue} className="px-3 py-1 bg-primary/10 text-primary rounded-full text-xs font-medium flex items-center gap-1">
                {cue} <button onClick={() => removeCue(cue)} className="hover:text-red-500 ml-1">×</button>
              </span>
            ))}
          </div>
          <input value={cueInput} onChange={(e) => setCueInput(e.target.value)} onKeyDown={addCue} className="field-input" placeholder="e.g. Ill-defined border" />
        </div>
        <div>
          <label className="field-label">Differential Note <span className="text-gray-400 font-normal">(optional)</span></label>
          <textarea value={feedback.differentialNote} onChange={(e) => setFeedback((f) => ({ ...f, differentialNote: e.target.value }))} className="field-input h-20 resize-none" placeholder="Brief note comparing to the main differential diagnoses…" />
        </div>
      </section>

      {/* 8. Concept Tags & Specialty Note */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={8} title="Tags & Notes" />
        <div>
          <label className="field-label">Concept Tags <span className="text-gray-400 font-normal">(press Enter to add)</span></label>
          <div className="flex flex-wrap gap-2 mb-2">
            {conceptTags.map((tag) => (
              <span key={tag} className="px-3 py-1 bg-gray-100 text-gray-600 rounded-full text-xs font-medium flex items-center gap-1">
                {tag} <button onClick={() => removeTag(tag)} className="hover:text-red-500 ml-1">×</button>
              </span>
            ))}
          </div>
          <input value={tagInput} onChange={(e) => setTagInput(e.target.value)} onKeyDown={addTag} className="field-input" placeholder="e.g. contact-dermatitis" />
        </div>
        <div>
          <label className="field-label">Specialty Note <span className="text-gray-400 font-normal">(optional clinical pearl)</span></label>
          <textarea value={specialtyNote} onChange={(e) => setSpecialtyNote(e.target.value)} className="field-input h-20 resize-none" placeholder="Teaching pearl or important clinical caveat…" />
        </div>
      </section>

      {/* Save footer */}
      <div className="flex items-center justify-between pt-2">
        <button onClick={() => router.push("/cases")} className="px-5 py-2 border border-gray-200 rounded-lg text-sm font-medium hover:bg-gray-50">
          Cancel
        </button>
        <button
          onClick={handleSave}
          disabled={saving}
          className="bg-primary text-white px-6 py-2 rounded-lg flex items-center gap-2 font-medium hover:bg-opacity-90 transition-all disabled:opacity-60"
        >
          {saving ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />}
          {saving ? "Saving…" : "Save Case"}
        </button>
      </div>
    </div>
  );
}

function SectionHeader({ number, title, subtitle }: { number: number; title: string; subtitle?: string }) {
  return (
    <div className="flex items-start gap-3 pb-2 border-b border-gray-100">
      <span className="bg-primary/10 text-primary w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold shrink-0 mt-0.5">
        {number}
      </span>
      <div>
        <h3 className="font-bold text-gray-900">{title}</h3>
        {subtitle && <p className="text-xs text-gray-500 mt-0.5">{subtitle}</p>}
      </div>
    </div>
  );
}
