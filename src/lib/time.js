// Lightweight relative-time helpers so we don't need a date library.

export function formatRelativeTime(dateInput) {
  const date = new Date(dateInput);
  const diffMs = Date.now() - date.getTime();
  const diffSec = Math.round(diffMs / 1000);

  const units = [
    ["year", 60 * 60 * 24 * 365],
    ["month", 60 * 60 * 24 * 30],
    ["day", 60 * 60 * 24],
    ["hour", 60 * 60],
    ["minute", 60],
  ];

  for (const [label, secondsInUnit] of units) {
    const value = Math.floor(Math.abs(diffSec) / secondsInUnit);
    if (value >= 1) {
      return diffSec >= 0 ? `${value} ${label}${value > 1 ? "s" : ""} ago` : `in ${value} ${label}${value > 1 ? "s" : ""}`;
    }
  }
  return diffSec >= 0 ? "just now" : "in a few seconds";
}

export function formatExactDateTime(dateInput) {
  return new Date(dateInput).toLocaleString(undefined, {
    dateStyle: "medium",
    timeStyle: "short",
  });
}

// Returns { label, msRemaining, isExpired, urgency } where urgency is
// "safe" | "warning" | "critical" based on how little time is left.
export function getCountdown(expiresAt) {
  if (!expiresAt) {
    return { label: "Never expires", msRemaining: null, isExpired: false, urgency: "safe" };
  }

  const msRemaining = new Date(expiresAt).getTime() - Date.now();

  if (msRemaining <= 0) {
    return { label: "Expired", msRemaining: 0, isExpired: true, urgency: "critical" };
  }

  const totalSeconds = Math.floor(msRemaining / 1000);
  const days = Math.floor(totalSeconds / 86400);
  const hours = Math.floor((totalSeconds % 86400) / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  let label;
  if (days > 0) label = `${days}d ${hours}h left`;
  else if (hours > 0) label = `${hours}h ${minutes}m left`;
  else if (minutes > 0) label = `${minutes}m ${seconds}s left`;
  else label = `${seconds}s left`;

  let urgency = "safe";
  if (msRemaining < 1000 * 60 * 5) urgency = "critical"; // under 5 minutes
  else if (msRemaining < 1000 * 60 * 60) urgency = "warning"; // under 1 hour

  return { label, msRemaining, isExpired: false, urgency };
}