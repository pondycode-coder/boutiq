"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { loginWithPin } from "@/lib/auth";

export default function LoginPage() {
  const router = useRouter();
  const [pin, setPin] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);
    const user = await loginWithPin(pin);
    setLoading(false);
    if (!user) {
      setError("Invalid PIN. Please try again.");
      return;
    }
    router.replace(user.role === "admin" ? "/dashboard" : "/pos");
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-brand-navy px-4">
      <div className="w-full max-w-sm rounded-lg bg-white p-8 shadow-lg">
        <div className="mb-6 text-center">
          <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-lg bg-brand-navy text-2xl font-bold text-brand-gold">
            B
          </div>
          <h1 className="mt-3 text-xl font-bold text-ink">Boutiq</h1>
          <p className="text-sm text-muted">Sign in with your PIN</p>
        </div>
        <form onSubmit={handleSubmit} className="space-y-4">
          <input
            type="password"
            inputMode="numeric"
            autoFocus
            value={pin}
            onChange={(e) => setPin(e.target.value)}
            placeholder="PIN"
            className="w-full rounded-md border border-slate-300 px-4 py-3 text-center text-lg tracking-widest outline-none focus:border-brand-blue"
          />
          {error && <p className="text-center text-sm text-red-600">{error}</p>}
          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-md bg-brand-blue py-3 font-semibold text-white hover:bg-brand-navy disabled:opacity-60"
          >
            {loading ? "Signing in..." : "Sign in"}
          </button>
        </form>
        <p className="mt-6 text-center text-xs text-muted">
          Support: pondycode@gmail.com · +237 674 667 234
        </p>
      </div>
    </div>
  );
}
