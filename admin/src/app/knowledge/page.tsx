"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { supabase } from "@/lib/supabase";
import { Plus, Search, Edit, BookOpen, ImageIcon, Loader2 } from "lucide-react";

export default function KnowledgePage() {
  const router = useRouter();
  const [conditions, setConditions] = useState<any[]>([]);
  const [imageCounts, setImageCounts] = useState<Record<string, number>>({});
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  useEffect(() => {
    async function load() {
      const [{ data: knowledge }, { data: images }] = await Promise.all([
        supabase.from("clinical_knowledge").select("*").order("topic"),
        supabase.from("clinical_images").select("condition"),
      ]);

      setConditions(knowledge ?? []);

      // Count images per condition (case-insensitive match)
      const counts: Record<string, number> = {};
      for (const img of images ?? []) {
        const key = img.condition.toLowerCase();
        counts[key] = (counts[key] ?? 0) + 1;
      }
      setImageCounts(counts);
      setLoading(false);
    }
    load();
  }, []);

  function getImageCount(topic: string) {
    const topicLower = topic.toLowerCase();
    return Object.entries(imageCounts).reduce((total, [key, count]) => {
      return key.includes(topicLower) || topicLower.includes(key) ? total + count : total;
    }, 0);
  }

  const filtered = conditions.filter((c) =>
    c.topic.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Knowledge Base</h1>
          <p className="text-gray-500 mt-1">Every condition, its clinical features, and related images.</p>
        </div>
        <button
          onClick={() => router.push("/knowledge/new")}
          className="bg-primary text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-opacity-90 transition-all font-medium"
        >
          <Plus size={18} />
          Add Condition
        </button>
      </div>

      {/* Search */}
      <div className="relative max-w-md">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search conditions…"
          className="w-full pl-9 pr-4 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
        />
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-48">
          <Loader2 className="animate-spin text-primary" size={28} />
        </div>
      ) : filtered.length === 0 ? (
        <div className="admin-card p-16 text-center">
          <p className="text-gray-400 text-sm">
            {conditions.length === 0
              ? 'No conditions yet. Click "Add Condition" to create the first one.'
              : "No conditions match your search."}
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {filtered.map((c) => {
            const imgCount = getImageCount(c.topic);
            const diffCount = (c.differential_diagnosis ?? []).length;
            const featuresCount = (c.clinical_features ?? []).length;
            const definitionSnippet = c.definition
              ? c.definition.slice(0, 130) + (c.definition.length > 130 ? "…" : "")
              : "No definition yet.";

            return (
              <div key={c.id} className="admin-card p-5 flex flex-col gap-3 hover:shadow-md transition-shadow">
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-start gap-3">
                    <div className="bg-primary/10 p-2 rounded-lg shrink-0 mt-0.5">
                      <BookOpen size={16} className="text-primary" />
                    </div>
                    <div>
                      <h3 className="font-bold text-gray-900">{c.topic}</h3>
                      <p className="text-xs text-gray-500 mt-1 leading-relaxed">{definitionSnippet}</p>
                    </div>
                  </div>
                  <button
                    onClick={() => router.push(`/knowledge/${c.id}`)}
                    className="text-gray-400 hover:text-primary transition-colors shrink-0"
                    title="Edit condition"
                  >
                    <Edit size={16} />
                  </button>
                </div>

                <div className="flex flex-wrap gap-2 pt-1 border-t border-gray-50">
                  {featuresCount > 0 && (
                    <span className="text-[10px] px-2 py-1 bg-primary/10 text-primary rounded-full font-semibold">
                      {featuresCount} features
                    </span>
                  )}
                  {diffCount > 0 && (
                    <span className="text-[10px] px-2 py-1 bg-gray-100 text-gray-600 rounded-full font-semibold">
                      {diffCount} differentials
                    </span>
                  )}
                  <span className={`text-[10px] px-2 py-1 rounded-full font-semibold flex items-center gap-1 ${
                    imgCount > 0 ? "bg-blue-100 text-blue-700" : "bg-gray-100 text-gray-400"
                  }`}>
                    <ImageIcon size={9} />
                    {imgCount > 0 ? `${imgCount} image${imgCount !== 1 ? "s" : ""}` : "no images"}
                  </span>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
