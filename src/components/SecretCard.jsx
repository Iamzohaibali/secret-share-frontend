import { Link } from "react-router-dom";
import { Lock, Flame, Eye, Tag } from "lucide-react";
import StatusBadge from "./StatusBadge.jsx";

export default function SecretCard({ secret, onDelete }) {
  return (
    <div className="group relative flex flex-col gap-3 rounded-2xl border border-white/10 bg-white/5 p-4 transition hover:border-indigo-400/40 hover:bg-white/[0.07]">
      <div className="flex items-start justify-between gap-2">
        <h3 className="line-clamp-1 font-semibold text-white">{secret.title}</h3>
        <StatusBadge secret={secret} />
      </div>

      <div className="flex flex-wrap items-center gap-2 text-xs text-slate-400">
        {secret.isPasswordProtected && (
          <span className="flex items-center gap-1">
            <Lock className="h-3.5 w-3.5" /> Password
          </span>
        )}
        {secret.burnAfterRead && (
          <span className="flex items-center gap-1">
            <Flame className="h-3.5 w-3.5" /> Burn after read
          </span>
        )}
        <span className="flex items-center gap-1">
          <Eye className="h-3.5 w-3.5" />
          {secret.viewCount}
          {secret.maxViews ? `/${secret.maxViews}` : ""} views
        </span>
      </div>

      {secret.tags?.length > 0 && (
        <div className="flex flex-wrap gap-1.5">
          {secret.tags.map((tag) => (
            <span
              key={tag}
              className="flex items-center gap-1 rounded-full bg-slate-800 px-2 py-0.5 text-[11px] text-slate-300"
            >
              <Tag className="h-3 w-3" /> {tag}
            </span>
          ))}
        </div>
      )}

      <div className="mt-1 flex items-center justify-between border-t border-white/5 pt-3">
        <Link
          to={`/secrets/${secret.id}`}
          className="text-sm font-medium text-indigo-400 hover:text-indigo-300"
        >
          View details â†’
        </Link>
        <button
          onClick={() => onDelete(secret.id)}
          className="text-sm text-slate-500 opacity-0 transition hover:text-red-400 group-hover:opacity-100"
        >
          Delete
        </button>
      </div>
    </div>
  );
}