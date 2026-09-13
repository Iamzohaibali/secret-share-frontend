import { useEffect, useState } from "react";
import { AlertTriangle, X } from "lucide-react";

export default function ConfirmDeleteModal({ open, title, onConfirm, onCancel, deleting = false }) {
  const [typedValue, setTypedValue] = useState("");
  const isMatch = typedValue.trim() === title;

  useEffect(() => {
    if (open) setTypedValue("");
  }, [open]);

  useEffect(() => {
    if (!open) return;
    const onKeyDown = (e) => {
      if (e.key === "Escape") onCancel();
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [open, onCancel]);

  if (!open) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (isMatch && !deleting) onConfirm();
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4 backdrop-blur-sm"
      onMouseDown={(e) => {
        if (e.target === e.currentTarget) onCancel();
      }}
    >
      <div className="w-full max-w-md rounded-2xl border border-white/10 bg-slate-900 p-6 shadow-xl">
        <div className="flex items-start justify-between gap-3">
          <div className="flex items-center gap-2">
            <div className="rounded-full bg-red-500/10 p-2">
              <AlertTriangle className="h-5 w-5 text-red-400" />
            </div>
            <h2 className="text-lg font-semibold text-white">Delete secret?</h2>
          </div>
          <button
            onClick={onCancel}
            aria-label="Close"
            className="rounded-md p-1 text-slate-400 hover:bg-white/10 hover:text-white"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <p className="mt-3 text-sm text-slate-400">
          This can't be undone. Type <span className="font-semibold text-white">{title}</span> below to
          confirm.
        </p>

        <form onSubmit={handleSubmit} className="mt-4 space-y-3">
          <input
            autoFocus
            value={typedValue}
            onChange={(e) => setTypedValue(e.target.value)}
            placeholder={title}
            className="w-full rounded-lg border border-white/10 bg-white/5 px-3 py-2.5 text-white placeholder:text-slate-600 focus:border-red-400 focus:outline-none"
          />

          <div className="flex gap-2">
            <button
              type="button"
              onClick={onCancel}
              className="flex-1 rounded-lg border border-white/10 py-2.5 text-sm font-medium text-white hover:bg-white/5"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={!isMatch || deleting}
              className="flex-1 rounded-lg bg-red-500 py-2.5 text-sm font-semibold text-white transition hover:bg-red-400 disabled:cursor-not-allowed disabled:opacity-40"
            >
              {deleting ? "Deleting..." : "Delete secret"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}