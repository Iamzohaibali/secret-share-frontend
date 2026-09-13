import { useState } from "react";
import { useAuth } from "@clerk/clerk-react";
import { useNavigate } from "react-router-dom";
import { Flame, Lock, Clock, Copy, Check } from "lucide-react";
import { api, attachAuthInterceptor } from "../lib/api.js";
import PasswordInput from "../components/PasswordInput.jsx";
import { formatExactDateTime } from "../lib/time.js";

const SECRET_TYPES = [
  { value: "text", label: "Plain text" },
  { value: "password", label: "Password" },
  { value: "apiKey", label: "API Key" },
  { value: "note", label: "Note" },
  { value: "other", label: "Other" },
];

const EXPIRY_PRESETS = [
  { label: "1 hour", hours: 1 },
  { label: "24 hours", hours: 24 },
  { label: "7 days", hours: 168 },
  { label: "30 days", hours: 720 },
  { label: "Custom date", hours: null },
  { label: "Never (until burned/deleted)", hours: "never" },
];

export default function CreateSecret() {
  const { getToken } = useAuth();
  const navigate = useNavigate();

  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [secretType, setSecretType] = useState("text");
  const [tagsInput, setTagsInput] = useState("");

  const [expiryChoice, setExpiryChoice] = useState(24);
  const [customDate, setCustomDate] = useState("");

  const [burnAfterRead, setBurnAfterRead] = useState(false);
  const [maxViews, setMaxViews] = useState("");

  const [usePassword, setUsePassword] = useState(false);
  const [password, setPassword] = useState("");

  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [shareLink, setShareLink] = useState("");
  const [copied, setCopied] = useState(false);

  const buildPayload = () => {
    const payload = {
      title,
      content,
      secretType,
      tags: tagsInput
        .split(",")
        .map((t) => t.trim())
        .filter(Boolean),
      burnAfterRead,
    };

    if (!burnAfterRead && maxViews) {
      payload.maxViews = Number(maxViews);
    }

    if (expiryChoice === "never") {
      // leave expiresAt unset
    } else if (expiryChoice === null) {
      if (customDate) payload.expiresAt = new Date(customDate).toISOString();
    } else {
      payload.expiresInHours = expiryChoice;
    }

    if (usePassword && password) {
      payload.password = password;
    }

    return payload;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    if (!title.trim() || !content.trim()) {
      setError("Title and content are required.");
      return;
    }

    try {
      setSubmitting(true);
      attachAuthInterceptor(getToken);
      const { data } = await api.post("/secrets", buildPayload());
      const link = `${window.location.origin}/s/${data.data.shareId}`;
      setShareLink(link);
    } catch (err) {
      setError(err.response?.data?.message || "Failed to create secret");
    } finally {
      setSubmitting(false);
    }
  };

  const handleCopy = async () => {
    await navigator.clipboard.writeText(shareLink);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  if (shareLink) {
    return (
      <div className="mx-auto max-w-xl px-4 py-16 sm:px-6">
        <div className="rounded-2xl border border-emerald-500/20 bg-emerald-500/5 p-6 text-center">
          <Check className="mx-auto mb-3 h-10 w-10 text-emerald-400" />
          <h2 className="text-xl font-semibold text-white">Secret created!</h2>
          <p className="mt-1 text-sm text-slate-400">
            Share this link with the recipient. It works exactly once per your settings.
          </p>
          <div className="mt-5 flex items-center gap-2 rounded-lg border border-white/10 bg-slate-900 p-2">
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
          <div className="mt-6 flex justify-center gap-3">
            <button
              onClick={() => navigate("/dashboard")}
              className="rounded-lg border border-white/10 px-4 py-2 text-sm text-white hover:bg-white/5"
            >
              Go to dashboard
            </button>
            <button
              onClick={() => window.location.reload()}
              className="rounded-lg bg-indigo-500 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-400"
            >
              Create another
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl px-4 py-10 sm:px-6">
      <h1 className="text-2xl font-bold text-white">Create a new secret</h1>
      <p className="mt-1 text-sm text-slate-400">
        Configure exactly how and when this secret should disappear.
      </p>

      <form onSubmit={handleSubmit} className="mt-8 space-y-6">
        <div>
          <label className="mb-1.5 block text-sm font-medium text-slate-300">Title</label>
          <input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="e.g. Staging DB password"
            className="w-full rounded-lg border border-white/10 bg-white/5 px-3 py-2.5 text-white placeholder:text-slate-500 focus:border-indigo-400 focus:outline-none"
          />
        </div>

        <div>
          <label className="mb-1.5 block text-sm font-medium text-slate-300">Secret type</label>
          <select
            value={secretType}
            onChange={(e) => setSecretType(e.target.value)}
            className="w-full rounded-lg border border-white/10 bg-white/5 px-3 py-2.5 text-white focus:border-indigo-400 focus:outline-none"
          >
            {SECRET_TYPES.map((t) => (
              <option key={t.value} value={t.value} className="bg-slate-900">
                {t.label}
              </option>
            ))}
          </select>
        </div>

        <div>
          <label className="mb-1.5 block text-sm font-medium text-slate-300">Content</label>
          <textarea
            value={content}
            onChange={(e) => setContent(e.target.value)}
            rows={5}
            placeholder="Paste the secret content here..."
            className="w-full rounded-lg border border-white/10 bg-white/5 px-3 py-2.5 font-mono text-sm text-white placeholder:text-slate-500 focus:border-indigo-400 focus:outline-none"
          />
        </div>

        <div>
          <label className="mb-1.5 block text-sm font-medium text-slate-300">
            Tags <span className="text-slate-500">(comma separated, optional)</span>
          </label>
          <input
            value={tagsInput}
            onChange={(e) => setTagsInput(e.target.value)}
            placeholder="prod, backend, urgent"
            className="w-full rounded-lg border border-white/10 bg-white/5 px-3 py-2.5 text-white placeholder:text-slate-500 focus:border-indigo-400 focus:outline-none"
          />
        </div>

        {/* Expiry */}
        <div className="rounded-xl border border-white/10 p-4">
          <div className="mb-3 flex items-center gap-2 text-sm font-medium text-slate-300">
            <Clock className="h-4 w-4 text-indigo-400" /> Expiry
          </div>
          <div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
            {EXPIRY_PRESETS.map((p) => (
              <button
                type="button"
                key={p.label}
                onClick={() => setExpiryChoice(p.hours)}
                className={`rounded-lg border px-3 py-2 text-xs font-medium transition ${
                  expiryChoice === p.hours
                    ? "border-indigo-400 bg-indigo-500/10 text-indigo-300"
                    : "border-white/10 text-slate-400 hover:border-white/20"
                }`}
              >
                {p.label}
              </button>
            ))}
          </div>
          {expiryChoice === null && (
            <input
              type="datetime-local"
              value={customDate}
              onChange={(e) => setCustomDate(e.target.value)}
              className="mt-3 w-full rounded-lg border border-white/10 bg-white/5 px-3 py-2 text-white focus:border-indigo-400 focus:outline-none"
            />
          )}

          {(() => {
            let preview = null;
            if (expiryChoice === "never") preview = "This secret will never expire on its own.";
            else if (expiryChoice === null && customDate) {
              preview = `Expires on ${formatExactDateTime(customDate)}`;
            } else if (typeof expiryChoice === "number") {
              const d = new Date(Date.now() + expiryChoice * 60 * 60 * 1000);
              preview = `Expires on ${formatExactDateTime(d)}`;
            }
            return preview ? (
              <p className="mt-2 text-xs text-slate-500">{preview}</p>
            ) : null;
          })()}
        </div>

        {/* Burn after read / max views */}
        <div className="rounded-xl border border-white/10 p-4">
          <label className="flex cursor-pointer items-center justify-between">
            <span className="flex items-center gap-2 text-sm font-medium text-slate-300">
              <Flame className="h-4 w-4 text-orange-400" /> Burn after first read
            </span>
            <input
              type="checkbox"
              checked={burnAfterRead}
              onChange={(e) => setBurnAfterRead(e.target.checked)}
              className="h-5 w-5 accent-indigo-500"
            />
          </label>

          {!burnAfterRead && (
            <div className="mt-3">
              <label className="mb-1.5 block text-sm text-slate-400">
                Max views <span className="text-slate-500">(leave blank for unlimited)</span>
              </label>
              <input
                type="number"
                min="1"
                value={maxViews}
                onChange={(e) => setMaxViews(e.target.value)}
                placeholder="e.g. 5"
                className="w-full rounded-lg border border-white/10 bg-white/5 px-3 py-2 text-white placeholder:text-slate-500 focus:border-indigo-400 focus:outline-none"
              />
            </div>
          )}
        </div>

        {/* Password protection */}
        <div className="rounded-xl border border-white/10 p-4">
          <label className="flex cursor-pointer items-center justify-between">
            <span className="flex items-center gap-2 text-sm font-medium text-slate-300">
              <Lock className="h-4 w-4 text-indigo-400" /> Password protect
            </span>
            <input
              type="checkbox"
              checked={usePassword}
              onChange={(e) => setUsePassword(e.target.checked)}
              className="h-5 w-5 accent-indigo-500"
            />
          </label>
          {usePassword && (
            <div className="mt-3">
              <PasswordInput
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Recipient will need this to view the secret"
              />
            </div>
          )}
        </div>

        {error && <p className="text-sm text-red-400">{error}</p>}

        <button
          type="submit"
          disabled={submitting}
          className="w-full rounded-lg bg-indigo-500 py-3 text-sm font-semibold text-white transition hover:bg-indigo-400 disabled:opacity-50"
        >
          {submitting ? "Creating..." : "Create secret & get link"}
        </button>
      </form>
    </div>
  );
}