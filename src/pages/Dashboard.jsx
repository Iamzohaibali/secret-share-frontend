import { useEffect, useState } from "react";
import { useAuth } from "@clerk/clerk-react";
import { useNavigate } from "react-router-dom";
import { Plus, Inbox } from "lucide-react";
import { api, attachAuthInterceptor } from "../lib/api.js";
import SecretCard from "../components/SecretCard.jsx";
import Loader from "../components/Loader.jsx";

export default function Dashboard() {
  const { getToken, isLoaded } = useAuth();
  const navigate = useNavigate();
  const [secrets, setSecrets] = useState([]);
  const [limit, setLimit] = useState(100);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!isLoaded) return;
    attachAuthInterceptor(getToken);
    fetchSecrets();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isLoaded]);

  const fetchSecrets = async () => {
    try {
      setLoading(true);
      const { data } = await api.get("/secrets");
      setSecrets(data.data);
      setLimit(data.limit);
    } catch (err) {
      setError(err.response?.data?.message || "Failed to load secrets");
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (!confirm("Delete this secret? This cannot be undone.")) return;
    try {
      await api.delete(`/secrets/${id}`);
      setSecrets((prev) => prev.filter((s) => s.id !== id));
    } catch (err) {
      alert(err.response?.data?.message || "Failed to delete secret");
    }
  };

  if (loading) return <Loader label="Loading your secrets..." />;

  return (
    <div className="mx-auto max-w-6xl px-4 py-10 sm:px-6">
      <div className="mb-8 flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white">Your Secrets</h1>
          <p className="text-sm text-slate-400">
            {secrets.length} / {limit} secrets used
          </p>
        </div>
        <button
          onClick={() => navigate("/create")}
          className="flex items-center gap-1.5 rounded-lg bg-indigo-500 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-400"
        >
          <Plus className="h-4 w-4" /> New Secret
        </button>
      </div>

      {error && <p className="mb-4 text-sm text-red-400">{error}</p>}

      {secrets.length === 0 ? (
        <div className="flex flex-col items-center justify-center gap-3 rounded-2xl border border-dashed border-white/10 py-20 text-center">
          <Inbox className="h-10 w-10 text-slate-600" />
          <p className="text-slate-400">You haven't created any secrets yet.</p>
          <button
            onClick={() => navigate("/create")}
            className="rounded-lg bg-indigo-500 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-400"
          >
            Create your first secret
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {secrets.map((secret) => (
            <SecretCard key={secret.id} secret={secret} onDelete={handleDelete} />
          ))}
        </div>
      )}
    </div>
  );
}