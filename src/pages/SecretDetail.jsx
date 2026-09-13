import { useEffect, useState } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import { useAuth } from "@clerk/clerk-react";
import { Copy, Check, ArrowLeft, Clock, Eye } from "lucide-react";
import { api, attachAuthInterceptor } from "../lib/api.js";
import Loader from "../components/Loader.jsx";
import StatusBadge from "../components/StatusBadge.jsx";
import { useCountdown } from "../hooks/useCountdown.js";
import { formatRelativeTime, formatExactDateTime } from "../lib/time.js";

export default function SecretDetail() {
  const { id } = useParams();
  const { getToken, isLoaded } = useAuth();
  const navigate = useNavigate();
  const [secret, setSecret] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    if (!isLoaded) return;
    attachAuthInterceptor(getToken);
    (async () => {
      try {
        const { data } = await api.get(`/secrets/${id}`);
        setSecret(data.data);
      } catch (err) {
        setError(err.response?.data?.message || "Failed to load secret");
      } finally {
        setLoading(false);
      }
    })();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isLoaded, id]);

  const countdown = useCountdown(secret?.expiresAt);
  const shareLink = secret ? `${window.location.origin}/s/${secret.shareId}` : "";

  const handleCopy = async () => {
    await navigator.clipboard.writeText(shareLink);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDelete = async () => {
    if (!confirm("Delete this secret? This cannot be undone.")) return;
    await api.delete(`/secrets/${id}`);
    navigate("/dashboard");
  };

  if (loading) return <Loader />;
  if (error) return <p className="p-10 text-center text-red-400">{error}</p>;

  return (
    <div className="mx-auto max-w-xl px-4 py-10 sm:px-6">
      <Link to="/dashboard" className="mb-6 flex items-center gap-1.5 text-sm text-slate-400 hover:text-white">
        <ArrowLeft className="h-4 w-4" /> Back to dashboard
      </Link>

      <div className="rounded-2xl border border-white/10 bg-white/5 p-6">
        <div className="flex items-start justify-between gap-3">
          <h1 className="text-xl font-bold text-white">{secret.title}</h1>
          <StatusBadge secret={secret} />
        </div>

        <dl className="mt-5 grid grid-cols-2 gap-y-3 text-sm">
          <dt className="text-slate-500">Type</dt>
          <dd className="text-slate-200">{secret.secretType}</dd>
          <dt className="text-slate-500">Created</dt>
          <dd className="text-slate-200" title={formatExactDateTime(secret.createdAt)}>
            {formatRelativeTime(secret.createdAt)}
          </dd>
          <dt className="text-slate-500">Password protected</dt>
          <dd className="text-slate-200">{secret.isPasswordProtected ? "Yes" : "No"}</dd>
          <dt className="text-slate-500">Burn after read</dt>
          <dd className="text-slate-200">{secret.burnAfterRead ? "Yes" : "No"}</dd>
          <dt className="text-slate-500">Expires</dt>
          <dd className="text-slate-200">
            {secret.expiresAt ? formatExactDateTime(secret.expiresAt) : "Never (until burned/deleted)"}
          </dd>
        </dl>

        {secret.expiresAt && !secret.isBurned && !countdown.isExpired && (
          <div
            className={`mt-3 flex items-center gap-2 rounded-lg px-3 py-2 text-sm font-medium ${
              countdown.urgency === "critical"
                ? "bg-red-500/10 text-red-400"
                : countdown.urgency === "warning"
                ? "bg-amber-500/10 text-amber-400"
                : "bg-emerald-500/10 text-emerald-400"
            }`}
          >
            <Clock className="h-4 w-4" />
            Time remaining: {countdown.label}
          </div>
        )}

        <div className="mt-4">
          <div className="mb-1 flex items-center justify-between text-xs text-slate-400">
            <span className="flex items-center gap-1">
              <Eye className="h-3.5 w-3.5" /> Views
            </span>
            <span>
              {secret.viewCount}
              {secret.maxViews ? ` / ${secret.maxViews}` : " (unlimited)"}
            </span>
          </div>
          {secret.maxViews ? (
            <div className="h-1.5 w-full overflow-hidden rounded-full bg-white/10">
              <div
                className="h-full rounded-full bg-indigo-500 transition-all"
                style={{
                  width: `${Math.min(100, (secret.viewCount / secret.maxViews) * 100)}%`,
                }}
              />
            </div>
          ) : null}
        </div>

        <p className="mt-5 rounded-lg bg-amber-500/10 p-3 text-xs text-amber-300">
          Note: opening the share link below counts as a view, just like it would for
          your recipient â€” so save this page instead of opening the link yourself
          unless you intend to reveal it.
        </p>

        <div className="mt-4 flex items-center gap-2 rounded-lg border border-white/10 bg-slate-900 p-2">
          <input
            readOnly
            value={shareLink}
            className="w-full truncate bg-transparent px-2 text-sm text-slate-300 outline-none"
          />
          <button
            onClick={handleCopy}
            className="flex shrink-0 items-center gap-1 rounded-md bg-indigo-500 px-3 py-1.5 text-sm font-medium text-white hover:bg-indigo-400"
          >
            {copied ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
            {copied ? "Copied" : "Copy"}
          </button>
        </div>

        <button
          onClick={handleDelete}
          className="mt-6 w-full rounded-lg border border-red-500/30 py-2.5 text-sm font-medium text-red-400 hover:bg-red-500/10"
        >
          Delete secret
        </button>
      </div>
    </div>
  );
}