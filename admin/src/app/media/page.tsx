"use client";

import { useEffect, useRef, useState } from "react";
import { supabase } from "@/lib/supabase";
import { Plus, Search, Trash2, Upload, X, Loader2 } from "lucide-react";

const TAG_CATEGORIES = [
  {
    label: "Body Region",
    values: ["face", "scalp", "neck", "trunk", "back", "arms", "hands", "legs", "feet", "oral-mucosa", "genital"],
  },
  {
    label: "Lesion Type",
    values: ["macule", "patch", "papule", "plaque", "vesicle", "bulla", "pustule", "nodule", "wheal", "cyst", "ulcer", "erosion", "scale", "crust", "lichenification", "atrophy"],
  },
  {
    label: "Distribution",
    values: ["localized", "generalized", "follicular", "annular", "linear", "dermatomal", "sun-exposed", "flexural", "extensor", "intertriginous"],
  },
  {
    label: "Severity",
    values: ["mild", "moderate", "severe"],
  },
];

const FITZPATRICK_TYPES = [
  { value: "I",   label: "I – Very fair",  bg: "bg-amber-50",      text: "text-amber-700",  dot: "#fef3c7" },
  { value: "II",  label: "II – Fair",       bg: "bg-amber-100",     text: "text-amber-800",  dot: "#fde68a" },
  { value: "III", label: "III – Medium",    bg: "bg-orange-100",    text: "text-orange-800", dot: "#fed7aa" },
  { value: "IV",  label: "IV – Olive",      bg: "bg-orange-200",    text: "text-orange-900", dot: "#fdba74" },
  { value: "V",   label: "V – Brown",       bg: "bg-orange-900/20", text: "text-orange-950", dot: "#92400e" },
  { value: "VI",  label: "VI – Dark",       bg: "bg-gray-800",      text: "text-gray-100",   dot: "#1f2937" },
];

export function FitzpatrickBadge({ type }: { type: string | null | undefined }) {
  const f = FITZPATRICK_TYPES.find((t) => t.value === type);
  if (!f) return (
    <span className="inline-flex items-center gap-1 text-[10px] font-semibold px-2 py-0.5 rounded-full bg-gray-100 text-gray-400 uppercase tracking-wide">
      Untagged
    </span>
  );
  return (
    <span className={`inline-flex items-center gap-1 text-[10px] font-bold px-2 py-0.5 rounded-full uppercase tracking-wide ${f.bg} ${f.text}`}>
      <span className="w-2 h-2 rounded-full inline-block shrink-0" style={{ background: f.dot }} />
      {f.label}
    </span>
  );
}

export default function MediaPage() {
  const [images, setImages] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [filterType, setFilterType] = useState("All");
  const [showPanel, setShowPanel] = useState(false);

  // Upload form
  const [uploadFile, setUploadFile] = useState<File | null>(null);
  const [uploadPreview, setUploadPreview] = useState<string | null>(null);
  const [condition, setCondition] = useState("");
  const [fitzpatrick, setFitzpatrick] = useState("");
  const [description, setDescription] = useState("");
  const [tags, setTags] = useState<string[]>([]);
  const [uploading, setUploading] = useState(false);
  const [uploadError, setUploadError] = useState("");

  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => { fetchImages(); }, []);

  async function fetchImages() {
    setLoading(true);
    const { data } = await supabase
      .from("clinical_images")
      .select("*")
      .order("created_at", { ascending: false });
    setImages(data ?? []);
    setLoading(false);
  }

  function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploadFile(file);
    setUploadPreview(URL.createObjectURL(file));
  }

  function toggleTag(tag: string) {
    setTags((prev) => prev.includes(tag) ? prev.filter((t) => t !== tag) : [...prev, tag]);
  }

  function resetForm() {
    setUploadFile(null);
    setUploadPreview(null);
    setCondition("");
    setFitzpatrick("I");
    setDescription("");
    setTags([]);
    setUploadError("");
  }

  async function handleUpload() {
    if (!uploadFile) { setUploadError("Please select an image."); return; }
    if (!condition.trim()) { setUploadError("Condition name is required."); return; }
    setUploadError("");
    setUploading(true);

    const ext = uploadFile.name.split(".").pop();
    const fileName = `${Date.now()}_ft${fitzpatrick}.${ext}`;

    const { data: storageData, error: storageError } = await supabase.storage
      .from("image-bank")
      .upload(fileName, uploadFile, { upsert: false });

    if (storageError || !storageData) {
      setUploadError(storageError?.message ?? "Upload failed.");
      setUploading(false);
      return;
    }

    const { data: { publicUrl } } = supabase.storage
      .from("image-bank")
      .getPublicUrl(storageData.path);

    const { error: dbError } = await supabase.from("clinical_images").insert({
      image_url: publicUrl,
      condition: condition.trim(),
      fitzpatrick: fitzpatrick || null,
      description: description.trim() || null,
      tags,
    });

    setUploading(false);
    if (dbError) { setUploadError(dbError.message); return; }

    resetForm();
    setShowPanel(false);
    fetchImages();
  }

  async function handleDelete(id: string, imageUrl: string) {
    if (!confirm("Remove this image from the bank? This cannot be undone.")) return;
    const path = imageUrl.split("/image-bank/")[1];
    if (path) await supabase.storage.from("image-bank").remove([path]);
    await supabase.from("clinical_images").delete().eq("id", id);
    setImages((prev) => prev.filter((img) => img.id !== id));
  }

  const filtered = images.filter((img) => {
    const matchSearch = img.condition.toLowerCase().includes(search.toLowerCase());
    const matchFilter = filterType === "All" || img.fitzpatrick === filterType;
    return matchSearch && matchFilter;
  });

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Image Bank</h1>
          <p className="text-gray-500 mt-1">
            Clinical reference images tagged by condition and Fitzpatrick skin type.
          </p>
        </div>
        <button
          onClick={() => { resetForm(); setShowPanel(true); }}
          className="bg-primary text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-opacity-90 transition-all font-medium"
        >
          <Plus size={18} />
          Add Image
        </button>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3 items-center">
        <div className="relative flex-1 min-w-48">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search by condition…"
            className="w-full pl-9 pr-4 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
          />
        </div>
        <div className="flex gap-2 flex-wrap">
          {["All", ...FITZPATRICK_TYPES.map((f) => f.value)].map((t) => (
            <button
              key={t}
              onClick={() => setFilterType(t)}
              className={`px-3 py-1.5 rounded-full text-xs font-semibold transition-all ${
                filterType === t ? "bg-primary text-white" : "bg-gray-100 text-gray-600 hover:bg-gray-200"
              }`}
            >
              {t === "All" ? "All Types" : `Type ${t}`}
            </button>
          ))}
        </div>
      </div>

      {/* Stat chips */}
      <div className="flex gap-3 flex-wrap">
        {FITZPATRICK_TYPES.map((f) => {
          const count = images.filter((img) => img.fitzpatrick === f.value).length;
          return (
            <div key={f.value} className="flex items-center gap-2 px-3 py-1.5 bg-white border border-gray-200 rounded-lg text-xs">
              <span className="w-2.5 h-2.5 rounded-full" style={{ background: f.dot }} />
              <span className="font-medium text-gray-700">Type {f.value}</span>
              <span className="text-gray-400">{count} image{count !== 1 ? "s" : ""}</span>
            </div>
          );
        })}
      </div>

      {/* Grid */}
      {loading ? (
        <div className="flex items-center justify-center h-48">
          <Loader2 className="animate-spin text-primary" size={28} />
        </div>
      ) : filtered.length === 0 ? (
        <div className="admin-card p-16 text-center">
          <p className="text-gray-400 text-sm">
            {images.length === 0
              ? 'No images yet. Click "Add Image" to upload the first one.'
              : "No images match your search or filter."}
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          {filtered.map((img) => (
            <div key={img.id} className="group relative admin-card overflow-hidden">
              <div className="aspect-square bg-gray-100 overflow-hidden">
                <img
                  src={img.image_url}
                  alt={img.condition}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                />
              </div>
              <div className="p-3 space-y-1.5">
                <p className="font-semibold text-gray-900 text-sm leading-tight">{img.condition}</p>
                <FitzpatrickBadge type={img.fitzpatrick} />
                {img.description && (
                  <p className="text-xs text-gray-500 line-clamp-2 mt-1">{img.description}</p>
                )}
                {img.tags?.length > 0 && (
                  <div className="flex flex-wrap gap-1 pt-1">
                    {img.tags.slice(0, 3).map((tag: string) => (
                      <span key={tag} className="text-[10px] bg-gray-100 text-gray-500 px-1.5 py-0.5 rounded-full">{tag}</span>
                    ))}
                    {img.tags.length > 3 && (
                      <span className="text-[10px] text-gray-400">+{img.tags.length - 3}</span>
                    )}
                  </div>
                )}
              </div>
              <button
                onClick={() => handleDelete(img.id, img.image_url)}
                className="absolute top-2 right-2 bg-white/90 text-gray-400 hover:text-red-500 p-1.5 rounded-full opacity-0 group-hover:opacity-100 transition-all shadow-sm"
              >
                <Trash2 size={13} />
              </button>
            </div>
          ))}
        </div>
      )}

      {/* Upload slide-over panel */}
      {showPanel && (
        <div className="fixed inset-0 z-50 flex">
          <div className="flex-1 bg-black/40" onClick={() => setShowPanel(false)} />
          <div className="w-full max-w-md bg-white h-full shadow-2xl flex flex-col">
            <div className="p-6 border-b border-gray-100 flex items-center justify-between shrink-0">
              <h2 className="text-lg font-bold text-gray-900">Add to Image Bank</h2>
              <button onClick={() => setShowPanel(false)} className="text-gray-400 hover:text-gray-700">
                <X size={20} />
              </button>
            </div>

            <div className="p-6 space-y-5 overflow-y-auto flex-1">
              {/* Drop zone */}
              <div
                onClick={() => fileInputRef.current?.click()}
                className={`border-2 border-dashed rounded-xl overflow-hidden cursor-pointer transition-colors ${
                  uploadPreview ? "border-primary" : "border-gray-200 hover:border-primary"
                }`}
              >
                {uploadPreview ? (
                  <img src={uploadPreview} alt="Preview" className="w-full max-h-56 object-contain bg-gray-50" />
                ) : (
                  <div className="p-10 text-center">
                    <Upload className="mx-auto text-gray-400 mb-2" size={24} />
                    <p className="text-sm font-medium text-gray-600">Click to upload image</p>
                    <p className="text-xs text-gray-400 mt-1">PNG, JPG up to 10MB</p>
                  </div>
                )}
              </div>
              <input ref={fileInputRef} type="file" accept="image/*" className="hidden" onChange={handleFileChange} />

              <div>
                <label className="field-label">Condition Name</label>
                <input value={condition} onChange={(e) => setCondition(e.target.value)} className="field-input" placeholder="e.g. Plaque Psoriasis" />
              </div>

              <div>
                <label className="field-label">Fitzpatrick Skin Type</label>
                <select value={fitzpatrick} onChange={(e) => setFitzpatrick(e.target.value)} className="field-input">
                  <option value="">Not specified (tag later)</option>
                  {FITZPATRICK_TYPES.map((f) => <option key={f.value} value={f.value}>{f.label}</option>)}
                </select>
                <p className="text-xs text-gray-400 mt-1">You can leave this blank and tag it later.</p>
              </div>

              <div>
                <label className="field-label">Description <span className="text-gray-400 font-normal">(optional)</span></label>
                <textarea value={description} onChange={(e) => setDescription(e.target.value)} className="field-input h-20 resize-none" placeholder="Brief description of what the image shows…" />
              </div>

              <div>
                <label className="field-label">Tags</label>
                <div className="space-y-3">
                  {TAG_CATEGORIES.map((cat) => (
                    <div key={cat.label}>
                      <p className="text-[11px] font-semibold text-gray-400 uppercase tracking-wide mb-1.5">{cat.label}</p>
                      <div className="flex flex-wrap gap-1.5">
                        {cat.values.map((tag) => (
                          <button
                            key={tag}
                            type="button"
                            onClick={() => toggleTag(tag)}
                            className={`px-2.5 py-1 rounded-full text-xs font-medium transition-all ${
                              tags.includes(tag)
                                ? "bg-primary text-white"
                                : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                            }`}
                          >
                            {tag}
                          </button>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {uploadError && (
                <p className="text-sm text-red-600 bg-red-50 px-3 py-2 rounded-lg">{uploadError}</p>
              )}

              <button
                onClick={handleUpload}
                disabled={uploading}
                className="w-full bg-primary text-white py-2.5 rounded-lg font-medium flex items-center justify-center gap-2 hover:bg-opacity-90 disabled:opacity-60"
              >
                {uploading ? <Loader2 size={16} className="animate-spin" /> : <Upload size={16} />}
                {uploading ? "Uploading…" : "Save to Image Bank"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
