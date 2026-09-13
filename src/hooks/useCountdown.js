import { useEffect, useState } from "react";
import { getCountdown } from "../lib/time.js";

// Re-renders every second (or every minute if far in the future) so any
// component using this always shows a live "time remaining" value.
export function useCountdown(expiresAt) {
  const [countdown, setCountdown] = useState(() => getCountdown(expiresAt));

  useEffect(() => {
    setCountdown(getCountdown(expiresAt));
    if (!expiresAt) return;

    const msRemaining = new Date(expiresAt).getTime() - Date.now();
    // Tick every second once we're inside the final hour so it feels live;
    // otherwise every minute is plenty and cheaper on re-renders.
    const intervalMs = msRemaining < 1000 * 60 * 60 ? 1000 : 60 * 1000;

    const id = setInterval(() => {
      setCountdown(getCountdown(expiresAt));
    }, intervalMs);

    return () => clearInterval(id);
  }, [expiresAt]);

  return countdown;
}