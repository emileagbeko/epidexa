"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { supabase } from "@/lib/supabase";
import { ChevronLeft, Plus, Trash2, Save, Loader2, ImageIcon, ExternalLink } from "lucide-react";

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

function uid() { return Math.random().toString(36).slice(2, 9); }

interface ListItem { id: string; value: string; }
interface KVItem { id: string; key: string; value: string; }

function toListItems(arr: string[] | null | undefined): ListItem[] {
  return (arr ?? []).map((v) => ({ id: uid(), value: v }));
}
function toKVItems(obj: Record<string, string> | null | undefined): KVItem[] {
  return Object.entries(obj ?? {}).map(([key, value]) => ({ id: uid(), key, value }));
}
function fromListItems(items: ListItem[]): string[] {
  return items.map((i) => i.value).filter(Boolean);
}
function fromKVItems(items: KVItem[]): Record<string, string> {
  return Object.fromEntries(items.filter((i) => i.key).map((i) => [i.key, i.value]));
}

export default function KnowledgeEditPage() {
  const params = useParams();
  const router = useRouter();
  const id = params.id as string;
  const isNew = id === "new";

  const [loading, setLoading] = useState(!isNew);
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState("");

  const [topic, setTopic] = useState("");
  const [definition, setDefinition] = useState("");
  const [clinicalFeatures, setClinicalFeatures] = useState<ListItem[]>([]);
  const [distribution, setDistribution] = useState<KVItem[]>([]);
  const [investigations, setInvestigations] = useState("");
  const [management, setManagement] = useState<ListItem[]>([]);
  const [complications, setComplications] = useState<ListItem[]>([]);
  const [differentialDiagnosis, setDifferentialDiagnosis] = useState<ListItem[]>([]);

  const [relatedImages, setRelatedImages] = useState<any[]>([]);

  useEffect(() => {
    if (!isNew) loadEntry();
  }, [id]);

  async function loadEntry() {
    setLoading(true);
    const { data } = await supabase
      .from("clinical_knowledge")
      .select("*")
      .eq("id", id)
      .single();

    if (data) {
      setTopic(data.topic ?? "");
      setDefinition(data.definition ?? "");
      setClinicalFeatures(toListItems(data.clinical_features));
      setDistribution(toKVItems(data.distribution));
      setInvestigations(data.investigations ?? "");
      setManagement(toListItems(data.management));
      setComplications(toListItems(data.complications));
      setDifferentialDiagnosis(toListItems(data.differential_diagnosis));
      loadRelatedImages(data.topic);
    }
    setLoading(false);
  }

  async function loadRelatedImages(topicName: string) {
    const { data } = await supabase
      .from("clinical_images")
      .select("*")
      .ilike("condition", `%${topicName}%`);
    setRelatedImages(data ?? []);
  }

  function addListItem(setter: React.Dispatch<React.SetStateAction<ListItem[]>>) {
    setter((prev) => [...prev, { id: uid(), value: "" }]);
  }
  function removeListItem(setter: React.Dispatch<React.SetStateAction<ListItem[]>>, id: string) {
    setter((prev) => prev.filter((i) => i.id !== id));
  }
  function updateListItem(setter: React.Dispatch<React.SetStateAction<ListItem[]>>, id: string, value: string) {
    setter((prev) => prev.map((i) => (i.id === id ? { ...i, value } : i)));
  }

  function addKVItem() { setDistribution((prev) => [...prev, { id: uid(), key: "", value: "" }]); }
  function removeKVItem(id: string) { setDistribution((prev) => prev.filter((i) => i.id !== id)); }
  function updateKVItem(id: string, field: "key" | "value", val: string) {
    setDistribution((prev) => prev.map((i) => (i.id === id ? { ...i, [field]: val } : i)));
  }

  async function handleSave() {
    if (!topic.trim()) { setSaveError("Condition name is required."); return; }
    setSaveError("");
    setSaving(true);

    const payload = {
      topic: topic.trim(),
      definition: definition.trim() || null,
      clinical_features: fromListItems(clinicalFeatures),
      distribution: fromKVItems(distribution),
      investigations: investigations.trim() || null,
      management: fromListItems(management),
      complications: fromListItems(complications),
      differential_diagnosis: fromListItems(differentialDiagnosis),
    };

    const { error } = isNew
      ? await supabase.from("clinical_knowledge").insert(payload)
      : await supabase.from("clinical_knowledge").update(payload).eq("id", id);

    setSaving(false);
    if (error) { setSaveError(error.message); }
    else { router.push("/knowledge"); }
  }

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
        <button onClick={() => router.push("/knowledge")} className="text-gray-400 hover:text-gray-700 transition-colors">
          <ChevronLeft size={24} />
        </button>
        <div className="flex-1">
          <h1 className="text-2xl font-bold text-gray-900">
            {isNew ? "New Condition" : topic || "Edit Condition"}
          </h1>
        </div>
        <button
          onClick={handleSave}
          disabled={saving}
          className="bg-primary text-white px-5 py-2 rounded-lg flex items-center gap-2 font-medium hover:bg-opacity-90 transition-all disabled:opacity-60"
        >
          {saving ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />}
          {saving ? "Saving…" : "Save"}
        </button>
      </div>

      {saveError && (
        <div className="bg-red-50 border border-red-200 text-red-700 text-sm px-4 py-3 rounded-lg">{saveError}</div>
      )}

      {/* 1. Condition Name */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={1} title="Condition Name" />
        <input value={topic} onChange={(e) => setTopic(e.target.value)} className="field-input" placeholder="e.g. Contact Dermatitis" />
      </section>

      {/* 2. Definition */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={2} title="Definition" />
        <textarea value={definition} onChange={(e) => setDefinition(e.target.value)} className="field-input h-28 resize-none" placeholder="Brief definition of the condition…" />
      </section>

      {/* 3. Clinical Features */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={3} title="Clinical Features" subtitle="Each item is one feature or symptom" />
        <div className="space-y-2">
          {clinicalFeatures.map((item) => (
            <div key={item.id} className="flex items-center gap-3">
              <input value={item.value} onChange={(e) => updateListItem(setClinicalFeatures, item.id, e.target.value)} className="flex-1 field-input py-1.5" placeholder="e.g. Pruritic, eczematous rash" />
              <button onClick={() => removeListItem(setClinicalFeatures, item.id)} className="text-gray-300 hover:text-red-500 transition-colors"><Trash2 size={14} /></button>
            </div>
          ))}
        </div>
        <button onClick={() => addListItem(setClinicalFeatures)} className="text-sm text-primary hover:text-primary/80 font-medium flex items-center gap-1">
          <Plus size={14} /> Add feature
        </button>
      </section>

      {/* 4. Distribution */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={4} title="Distribution" subtitle="Where on the body / in which patient group" />
        <div className="space-y-2">
          {distribution.map((item) => (
            <div key={item.id} className="flex items-center gap-2">
              <input value={item.key} onChange={(e) => updateKVItem(item.id, "key", e.target.value)} className="w-36 field-input py-1.5 shrink-0" placeholder="Group (e.g. Infants)" />
              <span className="text-gray-400 text-sm">→</span>
              <input value={item.value} onChange={(e) => updateKVItem(item.id, "value", e.target.value)} className="flex-1 field-input py-1.5" placeholder="Body areas (e.g. Face, scalp)" />
              <button onClick={() => removeKVItem(item.id)} className="text-gray-300 hover:text-red-500 transition-colors"><Trash2 size={14} /></button>
            </div>
          ))}
        </div>
        <button onClick={addKVItem} className="text-sm text-primary hover:text-primary/80 font-medium flex items-center gap-1">
          <Plus size={14} /> Add distribution
        </button>
      </section>

      {/* 5. Investigations */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={5} title="Investigations" />
        <textarea value={investigations} onChange={(e) => setInvestigations(e.target.value)} className="field-input h-20 resize-none" placeholder="Diagnostic approach and gold standard investigations…" />
      </section>

      {/* 6. Management */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={6} title="Management" subtitle="One step per item" />
        <div className="space-y-2">
          {management.map((item) => (
            <div key={item.id} className="flex items-center gap-3">
              <input value={item.value} onChange={(e) => updateListItem(setManagement, item.id, e.target.value)} className="flex-1 field-input py-1.5" placeholder="e.g. Regular emollients as soap substitute" />
              <button onClick={() => removeListItem(setManagement, item.id)} className="text-gray-300 hover:text-red-500 transition-colors"><Trash2 size={14} /></button>
            </div>
          ))}
        </div>
        <button onClick={() => addListItem(setManagement)} className="text-sm text-primary hover:text-primary/80 font-medium flex items-center gap-1">
          <Plus size={14} /> Add step
        </button>
      </section>

      {/* 7. Complications */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={7} title="Complications" />
        <div className="space-y-2">
          {complications.map((item) => (
            <div key={item.id} className="flex items-center gap-3">
              <input value={item.value} onChange={(e) => updateListItem(setComplications, item.id, e.target.value)} className="flex-1 field-input py-1.5" placeholder="e.g. Secondary bacterial infection" />
              <button onClick={() => removeListItem(setComplications, item.id)} className="text-gray-300 hover:text-red-500 transition-colors"><Trash2 size={14} /></button>
            </div>
          ))}
        </div>
        <button onClick={() => addListItem(setComplications)} className="text-sm text-primary hover:text-primary/80 font-medium flex items-center gap-1">
          <Plus size={14} /> Add complication
        </button>
      </section>

      {/* 8. Differential Diagnosis */}
      <section className="admin-card p-6 space-y-4">
        <SectionHeader number={8} title="Differential Diagnosis" />
        <div className="space-y-2">
          {differentialDiagnosis.map((item) => (
            <div key={item.id} className="flex items-center gap-3">
              <input value={item.value} onChange={(e) => updateListItem(setDifferentialDiagnosis, item.id, e.target.value)} className="flex-1 field-input py-1.5" placeholder="e.g. Atopic dermatitis" />
              <button onClick={() => removeListItem(setDifferentialDiagnosis, item.id)} className="text-gray-300 hover:text-red-500 transition-colors"><Trash2 size={14} /></button>
            </div>
          ))}
        </div>
        <button onClick={() => addListItem(setDifferentialDiagnosis)} className="text-sm text-primary hover:text-primary/80 font-medium flex items-center gap-1">
          <Plus size={14} /> Add differential
        </button>
      </section>

      {/* 9. Related Images */}
      <section className="admin-card p-6 space-y-4">
        <div className="flex items-start justify-between pb-2 border-b border-gray-100">
          <SectionHeader number={9} title="Related Images" subtitle="Images from the Image Bank tagged with this condition" />
          <button
            onClick={() => router.push("/media")}
            className="text-xs text-primary hover:text-primary/80 font-medium flex items-center gap-1 shrink-0 mt-1"
          >
            <ExternalLink size={12} />
            Add in Image Bank
          </button>
        </div>

        {relatedImages.length === 0 ? (
          <div className="flex items-center gap-3 p-4 bg-gray-50 rounded-xl border border-dashed border-gray-200">
            <ImageIcon size={18} className="text-gray-400 shrink-0" />
            <p className="text-sm text-gray-500">
              No images yet. Upload images in the{" "}
              <button onClick={() => router.push("/media")} className="text-primary underline">Image Bank</button>
              {" "}and tag them with <span className="font-mono font-semibold">{topic || "this condition name"}</span>.
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-3 gap-3">
            {relatedImages.map((img) => (
              <div key={img.id} className="rounded-xl overflow-hidden border border-gray-100 bg-white">
                <div className="aspect-square bg-gray-100 overflow-hidden">
                  <img src={img.image_url} alt={img.condition} className="w-full h-full object-cover" />
                </div>
                <div className="p-2 space-y-1">
                  <p className="text-xs font-medium text-gray-800 truncate">{img.condition}</p>
                  <FitzpatrickBadge type={img.fitzpatrick} />
                  {img.description && (
                    <p className="text-[10px] text-gray-400 line-clamp-2">{img.description}</p>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* Footer */}
      <div className="flex items-center justify-between pt-2">
        <button onClick={() => router.push("/knowledge")} className="px-5 py-2 border border-gray-200 rounded-lg text-sm font-medium hover:bg-gray-50">
          Cancel
        </button>
        <button
          onClick={handleSave}
          disabled={saving}
          className="bg-primary text-white px-6 py-2 rounded-lg flex items-center gap-2 font-medium hover:bg-opacity-90 transition-all disabled:opacity-60"
        >
          {saving ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />}
          {saving ? "Saving…" : "Save Condition"}
        </button>
      </div>
    </div>
  );
}

function SectionHeader({ number, title, subtitle }: { number: number; title: string; subtitle?: string }) {
  return (
    <div className="flex items-start gap-3">
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
