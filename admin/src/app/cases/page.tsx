"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { supabase } from "@/lib/supabase";
import { Plus, Search, Filter, MoreHorizontal, Edit, Trash2 } from "lucide-react";

export default function CasesPage() {
  const router = useRouter();
  const [cases, setCases] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  useEffect(() => {
    async function fetchCases() {
      const { data, error } = await supabase
        .from("clinical_cases")
        .select("id, title, difficulty, status, image_path, feedback, concept_tags")
        .order("created_at", { ascending: true });

      if (error || !data) {
        setCases([]);
      } else {
        setCases(
          data.map((c) => ({
            ...c,
            diagnosis: c.feedback?.correctDiagnosis ?? "—",
            hasImage: !!c.image_path,
          }))
        );
      }
      setLoading(false);
    }
    fetchCases();
  }, []);

  async function handleDelete(id: string) {
    if (!confirm("Delete this case? This cannot be undone.")) return;
    await supabase.from("clinical_cases").delete().eq("id", id);
    setCases((prev) => prev.filter((c) => c.id !== id));
  }

  const filtered = cases.filter(
    (c) =>
      c.title.toLowerCase().includes(search.toLowerCase()) ||
      c.diagnosis.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Clinical Cases</h1>
          <p className="text-gray-500 mt-1">Manage the medical scenarios available to students.</p>
        </div>
        <button
          onClick={() => router.push("/cases/new")}
          className="bg-primary text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-opacity-90 transition-all font-medium"
        >
          <Plus size={18} />
          Add New Case
        </button>
      </div>

      <div className="admin-card">
        <div className="p-4 border-b border-gray-100 flex gap-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={18} />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search cases..."
              className="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all text-sm"
            />
          </div>
          <button className="px-4 py-2 border border-gray-200 rounded-lg flex items-center gap-2 text-sm font-medium hover:bg-gray-50">
            <Filter size={16} />
            Filters
          </button>
        </div>

        <div className="overflow-x-auto">
          {loading ? (
            <div className="p-12 text-center text-gray-400 text-sm">Loading cases...</div>
          ) : filtered.length === 0 ? (
            <div className="p-12 text-center text-gray-400 text-sm">No cases found.</div>
          ) : (
            <table className="w-full text-left">
              <thead>
                <tr className="bg-gray-50 border-b border-gray-100">
                  <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Case Title</th>
                  <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Correct Diagnosis</th>
                  <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Difficulty</th>
                  <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Visual Aid</th>
                  <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Status</th>
                  <th className="px-6 py-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {filtered.map((c) => (
                  <tr key={c.id} className="hover:bg-gray-50/50 transition-colors">
                    <td className="px-6 py-4">
                      <span className="font-medium text-gray-900">{c.title}</span>
                      <p className="text-xs text-gray-400 mt-0.5">{c.id}</p>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">{c.diagnosis}</td>
                    <td className="px-6 py-4">
                      <span className={`text-[10px] px-2 py-1 rounded-full font-bold uppercase tracking-wider ${
                        c.difficulty === "beginner" ? "bg-green-100 text-green-700" :
                        c.difficulty === "intermediate" ? "bg-yellow-100 text-yellow-700" :
                        "bg-red-100 text-red-700"
                      }`}>
                        {c.difficulty}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`text-[10px] px-2 py-1 rounded-full font-bold uppercase tracking-wider ${
                        c.hasImage ? "bg-blue-100 text-blue-700" : "bg-gray-100 text-gray-700"
                      }`}>
                        {c.hasImage ? "Image" : "Text-Only"}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <div className={`w-1.5 h-1.5 rounded-full ${
                          c.status === "Published" ? "bg-green-500" : "bg-orange-500"
                        }`} />
                        <span className="text-sm text-gray-600">{c.status ?? "Draft"}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <button
                          onClick={() => router.push(`/cases/${c.id}`)}
                          className="text-gray-400 hover:text-primary transition-colors"
                          title="Edit case"
                        >
                          <Edit size={16} />
                        </button>
                        <button
                          onClick={() => handleDelete(c.id)}
                          className="text-gray-400 hover:text-red-500 transition-colors"
                          title="Delete case"
                        >
                          <Trash2 size={16} />
                        </button>
                        <button className="text-gray-400 hover:text-gray-900 transition-colors">
                          <MoreHorizontal size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
}
