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