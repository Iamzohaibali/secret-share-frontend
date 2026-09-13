# ============================================================
#  setup-frontend.ps1
#  Adds SecretShare source files (Clerk auth, pages, components,
#  routing, API client) on top of your existing Vite + Tailwind app.
#  Run this FROM INSIDE your frontend folder (the one with package.json
#  from `npm create vite@latest`), e.g.: .\setup-frontend.ps1
# ============================================================


$Base = Get-Location
Write-Host "Scaffolding into $($Base)" -ForegroundColor Cyan

$path = Join-Path $Base ".env.example"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
VITE_CLERK_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
VITE_API_URL=http://localhost:5000/api
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created .env.example" -ForegroundColor DarkGray

$path = Join-Path $Base "Dockerfile"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created Dockerfile" -ForegroundColor DarkGray

$path = Join-Path $Base "nginx.conf"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created nginx.conf" -ForegroundColor DarkGray

$path = Join-Path $Base "src/App.jsx"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
import { Routes, Route } from "react-router-dom";
import Navbar from "./components/Navbar.jsx";
import ProtectedRoute from "./components/ProtectedRoute.jsx";
import Landing from "./pages/Landing.jsx";
import Dashboard from "./pages/Dashboard.jsx";
import CreateSecret from "./pages/CreateSecret.jsx";
import SecretDetail from "./pages/SecretDetail.jsx";
import ShareView from "./pages/ShareView.jsx";
import NotFound from "./pages/NotFound.jsx";

export default function App() {
  return (
    <div className="min-h-screen bg-slate-950">
      <Navbar />
      <Routes>
        <Route path="/" element={<Landing />} />
        <Route path="/s/:shareId" element={<ShareView />} />
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          }
        />
        <Route
          path="/create"
          element={
            <ProtectedRoute>
              <CreateSecret />
            </ProtectedRoute>
          }
        />
        <Route
          path="/secrets/:id"
          element={
            <ProtectedRoute>
              <SecretDetail />
            </ProtectedRoute>
          }
        />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </div>
  );
}
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/App.jsx" -ForegroundColor DarkGray

$path = Join-Path $Base "src/index.css"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
@import "tailwindcss";

html {
  color-scheme: dark;
}

body {
  font-family: "Inter", ui-sans-serif, system-ui, -apple-system, sans-serif;
}
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/index.css" -ForegroundColor DarkGray

$path = Join-Path $Base "src/main.jsx"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import { ClerkProvider } from "@clerk/clerk-react";
import App from "./App.jsx";
import "./index.css";

const PUBLISHABLE_KEY = import.meta.env.VITE_CLERK_PUBLISHABLE_KEY;

if (!PUBLISHABLE_KEY) {
  throw new Error("Missing VITE_CLERK_PUBLISHABLE_KEY in your .env file");
}

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <ClerkProvider publishableKey={PUBLISHABLE_KEY} afterSignOutUrl="/">
      <BrowserRouter>
        <App />
      </BrowserRouter>
    </ClerkProvider>
  </StrictMode>
);
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/main.jsx" -ForegroundColor DarkGray

$path = Join-Path $Base "src/components/Loader.jsx"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
export default function Loader({ label = "Loading..." }) {
  return (
    <div className="flex flex-col items-center justify-center gap-3 py-16 text-slate-400">
      <div className="h-8 w-8 animate-spin rounded-full border-2 border-slate-600 border-t-indigo-400" />
      <p className="text-sm">{label}</p>
    </div>
  );
}
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/components/Loader.jsx" -ForegroundColor DarkGray

$path = Join-Path $Base "src/components/Navbar.jsx"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
import { Link, useNavigate } from "react-router-dom";
import { SignedIn, SignedOut, SignInButton, UserButton } from "@clerk/clerk-react";
import { ShieldCheck, Plus } from "lucide-react";

export default function Navbar() {
  const navigate = useNavigate();

  return (
    <header className="sticky top-0 z-40 border-b border-white/10 bg-slate-950/80 backdrop-blur">
      <div className="mx-auto flex max-w-6xl items-center justify-between px-4 py-3 sm:px-6">
        <Link to="/" className="flex items-center gap-2">
          <div className="rounded-lg bg-gradient-to-br from-indigo-500 to-fuchsia-500 p-1.5">
            <ShieldCheck className="h-5 w-5 text-white" />
          </div>
          <span className="text-lg font-semibold tracking-tight text-white">
            SecretShare
          </span>
        </Link>

        <div className="flex items-center gap-3">
          <SignedIn>
            <button
              onClick={() => navigate("/create")}
              className="flex items-center gap-1.5 rounded-lg bg-indigo-500 px-3 py-2 text-sm font-medium text-white transition hover:bg-indigo-400 sm:px-4"
            >
              <Plus className="h-4 w-4" />
              <span className="hidden sm:inline">New Secret</span>
            </button>
            <Link
              to="/dashboard"
              className="hidden text-sm font-medium text-slate-300 transition hover:text-white sm:block"
            >
              Dashboard
            </Link>
            <UserButton afterSignOutUrl="/" />
          </SignedIn>
          <SignedOut>
            <SignInButton mode="modal">
              <button className="rounded-lg bg-white px-4 py-2 text-sm font-semibold text-slate-900 transition hover:bg-slate-200">
                Sign in
              </button>
            </SignInButton>
          </SignedOut>
        </div>
      </div>
    </header>
  );
}
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/components/Navbar.jsx" -ForegroundColor DarkGray

$path = Join-Path $Base "src/components/ProtectedRoute.jsx"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
import { SignedIn, SignedOut, RedirectToSignIn } from "@clerk/clerk-react";

export default function ProtectedRoute({ children }) {
  return (
    <>
      <SignedIn>{children}</SignedIn>
      <SignedOut>
        <RedirectToSignIn />
      </SignedOut>
    </>
  );
}
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/components/ProtectedRoute.jsx" -ForegroundColor DarkGray

$path = Join-Path $Base "src/components/SecretCard.jsx"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
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
          View details →
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
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/components/SecretCard.jsx" -ForegroundColor DarkGray

$path = Join-Path $Base "src/components/StatusBadge.jsx"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
function timeLeft(expiresAt) {
  if (!expiresAt) return null;
  const diff = new Date(expiresAt).getTime() - Date.now();
  if (diff <= 0) return "expired";
  const hours = Math.floor(diff / (1000 * 60 * 60));
  if (hours >= 24) return `${Math.floor(hours / 24)}d left`;
  if (hours >= 1) return `${hours}h left`;
  return `${Math.max(1, Math.floor(diff / (1000 * 60)))}m left`;
}

export default function StatusBadge({ secret }) {
  if (secret.isBurned) {
    return (
      <span className="rounded-full bg-red-500/10 px-2.5 py-1 text-xs font-medium text-red-400">
        🔥 Burned
      </span>
    );
  }
  if (secret.isExpired) {
    return (
      <span className="rounded-full bg-slate-500/10 px-2.5 py-1 text-xs font-medium text-slate-400">
        Expired
      </span>
    );
  }
  const left = timeLeft(secret.expiresAt);
  return (
    <span className="rounded-full bg-emerald-500/10 px-2.5 py-1 text-xs font-medium text-emerald-400">
      {left ? `⏳ ${left}` : "Active"}
    </span>
  );
}
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/components/StatusBadge.jsx" -ForegroundColor DarkGray

$path = Join-Path $Base "src/lib/api.js"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
import axios from "axios";

const BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:5000/api";

export const api = axios.create({ baseURL: BASE_URL });

// Call this once (e.g. inside a top-level component) with Clerk's getToken
// so every request automatically carries the Clerk session token.
export const attachAuthInterceptor = (getToken) => {
  api.interceptors.request.use(async (config) => {
    const token = await getToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  });
};
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/lib/api.js" -ForegroundColor DarkGray

$path = Join-Path $Base "src/pages/CreateSecret.jsx"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
import { useState } from "react";
import { useAuth } from "@clerk/clerk-react";
import { useNavigate } from "react-router-dom";
import { Flame, Lock, Clock, Copy, Check } from "lucide-react";
import { api, attachAuthInterceptor } from "../lib/api.js";

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
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Recipient will need this to view the secret"
              className="mt-3 w-full rounded-lg border border-white/10 bg-white/5 px-3 py-2 text-white placeholder:text-slate-500 focus:border-indigo-400 focus:outline-none"
            />
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
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/pages/CreateSecret.jsx" -ForegroundColor DarkGray

$path = Join-Path $Base "src/pages/Dashboard.jsx"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
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
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/pages/Dashboard.jsx" -ForegroundColor DarkGray

$path = Join-Path $Base "src/pages/Landing.jsx"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
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
    desc: "Content is encrypted at rest — even a database leak reveals nothing.",
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
          Passwords, API keys, and private notes — sent as one-time links that
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
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/pages/Landing.jsx" -ForegroundColor DarkGray

$path = Join-Path $Base "src/pages/NotFound.jsx"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
import { Link } from "react-router-dom";

export default function NotFound() {
  return (
    <div className="mx-auto max-w-md px-4 py-24 text-center">
      <h1 className="text-3xl font-bold text-white">404</h1>
      <p className="mt-2 text-slate-400">This page doesn't exist.</p>
      <Link to="/" className="mt-5 inline-block text-indigo-400 hover:text-indigo-300">
        Go back home
      </Link>
    </div>
  );
}
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/pages/NotFound.jsx" -ForegroundColor DarkGray

$path = Join-Path $Base "src/pages/SecretDetail.jsx"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
import { useEffect, useState } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import { useAuth } from "@clerk/clerk-react";
import { Copy, Check, ArrowLeft } from "lucide-react";
import { api, attachAuthInterceptor } from "../lib/api.js";
import Loader from "../components/Loader.jsx";
import StatusBadge from "../components/StatusBadge.jsx";

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
          <dt className="text-slate-500">Password protected</dt>
          <dd className="text-slate-200">{secret.isPasswordProtected ? "Yes" : "No"}</dd>
          <dt className="text-slate-500">Burn after read</dt>
          <dd className="text-slate-200">{secret.burnAfterRead ? "Yes" : "No"}</dd>
          <dt className="text-slate-500">Views</dt>
          <dd className="text-slate-200">
            {secret.viewCount}
            {secret.maxViews ? ` / ${secret.maxViews}` : " (unlimited)"}
          </dd>
          <dt className="text-slate-500">Expires</dt>
          <dd className="text-slate-200">
            {secret.expiresAt ? new Date(secret.expiresAt).toLocaleString() : "Never (until burned/deleted)"}
          </dd>
        </dl>

        <p className="mt-5 rounded-lg bg-amber-500/10 p-3 text-xs text-amber-300">
          Note: opening the share link below counts as a view, just like it would for
          your recipient — so save this page instead of opening the link yourself
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
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/pages/SecretDetail.jsx" -ForegroundColor DarkGray

$path = Join-Path $Base "src/pages/ShareView.jsx"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { Lock, Flame, Copy, Check, ShieldAlert } from "lucide-react";
import { api } from "../lib/api.js";
import Loader from "../components/Loader.jsx";

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
          <div className="mt-4 flex items-start gap-2 rounded-lg border border-white/10 bg-slate-950 p-4">
            <pre className="max-h-72 w-full overflow-auto whitespace-pre-wrap break-words font-mono text-sm text-slate-200">
              {revealed.content}
            </pre>
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

        <form onSubmit={handleReveal} className="mt-6 space-y-3 text-left">
          {meta.isPasswordProtected && (
            <div>
              <label className="mb-1.5 block text-sm font-medium text-slate-300">
                This secret is password protected
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter password"
                className="w-full rounded-lg border border-white/10 bg-white/5 px-3 py-2.5 text-white placeholder:text-slate-500 focus:border-indigo-400 focus:outline-none"
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
'@
Set-Content -Path $path -Value $content -NoNewline -Encoding utf8
Write-Host "  created src/pages/ShareView.jsx" -ForegroundColor DarkGray

# ---- install extra deps + create a real .env prefilled with your Clerk key ----
Write-Host "Installing frontend dependencies..." -ForegroundColor Cyan
npm install react-router-dom @clerk/clerk-react axios lucide-react

$envContent = @"
VITE_CLERK_PUBLISHABLE_KEY=pk_test_ZGVlcC1ncmFja2xlLTY3NDkuY2xlcmsuYWNjb3VudHMuZGV2JA
VITE_API_URL=http://localhost:5000/api
"@
Set-Content -Path ".env" -Value $envContent -NoNewline -Encoding utf8

Write-Host ""
Write-Host "Frontend source files created (App.jsx, pages, components, Clerk setup)." -ForegroundColor Green
Write-Host "A .env with your Clerk publishable key was created." -ForegroundColor Yellow
Write-Host "Run:  npm run dev" -ForegroundColor Cyan