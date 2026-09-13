import { useCountdown } from "../hooks/useCountdown.js";
import { formatExactDateTime } from "../lib/time.js";

const URGENCY_STYLES = {
  safe: "bg-emerald-500/10 text-emerald-400",
  warning: "bg-amber-500/10 text-amber-400",
  critical: "bg-red-500/10 text-red-400",
};

export default function StatusBadge({ secret }) {
  const countdown = useCountdown(secret.expiresAt);

  if (secret.isBurned) {
    return (
      <span className="rounded-full bg-red-500/10 px-2.5 py-1 text-xs font-medium text-red-400">
        ðŸ”¥ Burned
      </span>
    );
  }
  if (secret.isExpired || countdown.isExpired) {
    return (
      <span className="rounded-full bg-slate-500/10 px-2.5 py-1 text-xs font-medium text-slate-400">
        Expired
      </span>
    );
  }

  const title = secret.expiresAt ? `Expires ${formatExactDateTime(secret.expiresAt)}` : "No expiry set";

  return (
    <span
      title={title}
      className={`rounded-full px-2.5 py-1 text-xs font-medium ${URGENCY_STYLES[countdown.urgency]}`}
    >
      {secret.expiresAt ? `â³ ${countdown.label}` : "Active"}
    </span>
  );
}