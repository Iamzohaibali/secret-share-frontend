import { SignedIn, SignedOut, SignInButton } from "@clerk/clerk-react";
import { useNavigate } from "react-router-dom";
import { Lock, Flame, Clock, ShieldCheck, KeyRound, Eye } from "lucide-react";

const FEATURES = [
  {
    icon: Flame,
    title: "Burn after reading",
    desc: "Secrets self-destruct the instant they're viewed, no trace left behind.",
  },
  {
    icon: Clock,
    title: "Flexible expiry",
    desc: "Expire after a fixed number of hours, or pick an exact date and time.",
  },
  {
    icon: Lock,
    title: "Password protection",
    desc: "Add an extra password gate on top of the unguessable share link.",
  },
  {
    icon: Eye,
    title: "View limits",
    desc: "Cap how many times a link can be opened before it's gone for good.",
  },
  {
    icon: KeyRound,
    title: "AES-256 encryption",
    desc: "Content is encrypted at rest â€” even a database leak reveals nothing.",
  },
  {
    icon: ShieldCheck,
    title: "Your account, your secrets",
    desc: "Secure sign-in via Clerk keeps every secret tied to you alone.",
  },
];

export default function Landing() {
  const navigate = useNavigate();

  return (
    <div className="mx-auto max-w-6xl px-4 pb-24 pt-16 sm:px-6">
      <section className="text-center">
        <span className="inline-flex items-center gap-1.5 rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs text-slate-300">
          <ShieldCheck className="h-3.5 w-3.5 text-indigo-400" />
          Encrypted, self-destructing links
        </span>
        <h1 className="mt-6 text-4xl font-bold tracking-tight text-white sm:text-6xl">
          Share secrets that{" "}
          <span className="bg-gradient-to-r from-indigo-400 to-fuchsia-400 bg-clip-text text-transparent">
            disappear
          </span>{" "}
          on their own.
        </h1>
        <p className="mx-auto mt-5 max-w-2xl text-base text-slate-400 sm:text-lg">
          Passwords, API keys, and private notes â€” sent as one-time links that
          expire by time, by view count, or the moment they're opened.
        </p>

        <div className="mt-8 flex items-center justify-center gap-3">
          <SignedOut>
            <SignInButton mode="modal">
              <button className="rounded-lg bg-indigo-500 px-6 py-3 text-sm font-semibold text-white transition hover:bg-indigo-400">
                Get started free
              </button>
            </SignInButton>
          </SignedOut>
          <SignedIn>
            <button
              onClick={() => navigate("/create")}
              className="rounded-lg bg-indigo-500 px-6 py-3 text-sm font-semibold text-white transition hover:bg-indigo-400"
            >
              Create a secret
            </button>
            <button
              onClick={() => navigate("/dashboard")}
              className="rounded-lg border border-white/10 px-6 py-3 text-sm font-semibold text-white transition hover:bg-white/5"
            >
              View dashboard
            </button>
          </SignedIn>
        </div>
      </section>

      <section className="mt-24 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {FEATURES.map(({ icon: Icon, title, desc }) => (
          <div
            key={title}
            className="rounded-2xl border border-white/10 bg-white/5 p-5 transition hover:border-indigo-400/30"
          >
            <div className="mb-3 w-fit rounded-lg bg-indigo-500/10 p-2">
              <Icon className="h-5 w-5 text-indigo-400" />
            </div>
            <h3 className="font-semibold text-white">{title}</h3>
            <p className="mt-1 text-sm text-slate-400">{desc}</p>
          </div>
        ))}
      </section>
    </div>
  );
}