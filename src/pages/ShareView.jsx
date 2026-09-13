import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { Lock, Flame, Copy, Check, ShieldAlert, Clock, Eye, EyeOff } from "lucide-react";
import { api } from "../lib/api.js";
import Loader from "../components/Loader.jsx";
import PasswordInput from "../components/PasswordInput.jsx";
import { useCountdown } from "../hooks/useCountdown.js";

export default function ShareView() {
  const { shareId } = useParams();
  const [meta, setMeta] = useState(null);
  const [loading, setLoading] = useState(true);
  const [notFound, setNotFound] = useState(false);

  const [password, setPassword] = useState("");
  const [revealError, setRevealError] = useState("");
  const [revealing, setRevealing] = useState(false);
  const [revealed, setRevealed] = useState(null);
  const [copied, setCopied] = useState(false);
  const [contentVisible, setContentVisible] = useState(false);

  const countdown = useCountdown(meta?.expiresAt);

  useEffect(() => {
    (async () => {
      try {
        const { data } = await api.get(`/share/${shareId}`);
        setMeta(data.data);
      } catch (err) {
        setNotFound(true);
      } finally {
        setLoading(false);
      }
    })();
  }, [shareId]);

  const handleReveal = async (e) => {
    e.preventDefault();
    setRevealError("");
    try {
      setRevealing(true);
      const { data } = await api.post(`/share/${shareId}/reveal`, { password });
      setRevealed(data.data);
    } catch (err) {
      setRevealError(err.response?.data?.message || "Unable to reveal this secret");
    } finally {
      setRevealing(false);
    }
  };

  const handleCopy = async () => {
    await navigator.clipboard.writeText(revealed.content);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  if (loading) return <Loader label="Checking link..." />;

  if (notFound) {
    return (
      <div className="mx-auto max-w-md px-4 py-24 text-center">
        <ShieldAlert className="mx-auto mb-3 h-10 w-10 text-slate-500" />
        <h1 className="text-xl font-bold text-white">Link unavailable</h1>
        <p className="mt-2 text-sm text-slate-400">
          This secret doesn't exist, has already been viewed, or has expired.
        </p>
      </div>
    );
  }

  if (revealed) {
    return (
      <div className="mx-auto max-w-lg px-4 py-16 sm:px-6">
        <div className="rounded-2xl border border-white/10 bg-white/5 p-6">
          <h1 className="text-xl font-bold text-white">{revealed.title}</h1>
          {revealed.wasBurned && (
            <p className="mt-1 flex items-center gap-1.5 text-xs text-orange-400">
              <Flame className="h-3.5 w-3.5" /> This secret has now been destroyed and can't be viewed again.
            </p>
          )}
          <div className="relative mt-4 rounded-lg border border-white/10 bg-slate-950 p-4">
            <pre
              className={`max-h-72 w-full overflow-auto whitespace-pre-wrap break-words pr-8 font-mono text-sm text-slate-200 transition ${
                contentVisible ? "" : "blur-sm select-none"
              }`}
            >
              {revealed.content}
            </pre>
            <button
              type="button"
              onClick={() => setContentVisible((v) => !v)}
              aria-label={contentVisible ? "Hide secret" : "Show secret"}
              className="absolute right-3 top-3 rounded-md bg-white/5 p-1.5 text-slate-400 transition hover:bg-white/10 hover:text-white"
            >
              {contentVisible ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
            </button>
          </div>
          <button
            onClick={handleCopy}
            className="mt-4 flex w-full items-center justify-center gap-2 rounded-lg bg-indigo-500 py-2.5 text-sm font-medium text-white hover:bg-indigo-400"
          >
            {copied ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
            {copied ? "Copied" : "Copy to clipboard"}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-md px-4 py-16 sm:px-6">
      <div className="rounded-2xl border border-white/10 bg-white/5 p-6 text-center">
        <div className="mx-auto mb-3 w-fit rounded-full bg-indigo-500/10 p-3">
          <Lock className="h-6 w-6 text-indigo-400" />
        </div>
        <h1 className="text-xl font-bold text-white">{meta.title}</h1>
        <p className="mt-1 text-sm text-slate-400">
          Someone shared a secret with you.
          {meta.burnAfterRead && " It will be destroyed the moment you view it."}
        </p>

        {meta.expiresAt && !countdown.isExpired && (
          <div
            className={`mx-auto mt-3 flex w-fit items-center gap-1.5 rounded-full px-3 py-1 text-xs font-medium ${
              countdown.urgency === "critical"
                ? "bg-red-500/10 text-red-400"
                : countdown.urgency === "warning"
                ? "bg-amber-500/10 text-amber-400"
                : "bg-emerald-500/10 text-emerald-400"
            }`}
          >
            <Clock className="h-3.5 w-3.5" /> {countdown.label}
          </div>
        )}

        {meta.maxViews ? (
          <p className="mt-2 text-xs text-slate-500">
            {Math.max(meta.maxViews - meta.viewCount, 0)} view{meta.maxViews - meta.viewCount === 1 ? "" : "s"}{" "}
            remaining before this link stops working
          </p>
        ) : null}

        <form onSubmit={handleReveal} className="mt-6 space-y-3 text-left">
          {meta.isPasswordProtected && (
            <div>
              <label className="mb-1.5 block text-sm font-medium text-slate-300">
                This secret is password protected
              </label>
              <PasswordInput
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter password"
                autoFocus
              />
            </div>
          )}
          {revealError && <p className="text-sm text-red-400">{revealError}</p>}
          <button
            type="submit"
            disabled={revealing}
            className="w-full rounded-lg bg-indigo-500 py-2.5 text-sm font-semibold text-white hover:bg-indigo-400 disabled:opacity-50"
          >
            {revealing ? "Revealing..." : "Reveal secret"}
          </button>
        </form>
      </div>
    </div>
  );
}