"use client";

import { useRouter, usePathname } from "next/navigation";
import Link from "next/link";
import { ReactNode, useEffect, useState } from "react";
import { getSession, logout, isAdmin } from "@/lib/auth";
import type { AppUser } from "@/lib/types";

interface NavItem {
  href: string;
  label: string;
  icon: string;
  adminOnly?: boolean;
}

const NAV: NavItem[] = [
  { href: "/dashboard", label: "Dashboard", icon: "▦" },
  { href: "/pos", label: "POS", icon: "▣" },
  { href: "/products", label: "Products", icon: "▤" },
  { href: "/orders", label: "Orders", icon: "▥" },
  { href: "/clients", label: "Clients", icon: "◍", adminOnly: true },
  { href: "/staff", label: "Staff", icon: "◉", adminOnly: true },
  { href: "/settings", label: "Settings", icon: "⚙" },
];

export default function AppShell({ children }: { children: ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const [user, setUser] = useState<AppUser | null>(null);

  useEffect(() => {
    const s = getSession();
    if (!s) {
      router.replace("/login");
      return;
    }
    setUser(s);
  }, [router]);

  function handleLogout() {
    logout();
    router.replace("/login");
  }

  if (!user) return null;

  const items = NAV.filter((n) => !n.adminOnly || isAdmin(user));

  return (
    <div className="flex min-h-screen">
      <aside className="hidden w-60 flex-col border-r border-slate-200 bg-brand-navy text-white md:flex">
        <div className="px-5 py-5 text-xl font-bold tracking-tight">
          Boutiq
        </div>
        <nav className="flex-1 space-y-1 px-3">
          {items.map((n) => {
            const active = pathname === n.href;
            return (
              <Link
                key={n.href}
                href={n.href}
                className={`flex items-center gap-3 rounded-md px-3 py-2 text-sm ${
                  active
                    ? "bg-white/15 font-semibold"
                    : "text-white/70 hover:bg-white/10"
                }`}
              >
                <span className="text-base">{n.icon}</span>
                {n.label}
              </Link>
            );
          })}
        </nav>
        <div className="border-t border-white/10 p-4 text-xs text-white/60">
          <p className="font-medium text-white/90">{user.name}</p>
          <p className="capitalize">{user.role}</p>
        </div>
      </aside>

      <div className="flex flex-1 flex-col">
        <header className="flex items-center justify-between border-b border-slate-200 bg-white px-4 py-3 md:px-6">
          <div className="md:hidden text-lg font-bold text-brand-navy">
            Boutiq
          </div>
          <div className="ml-auto flex items-center gap-3">
            <span className="hidden text-sm text-muted sm:inline">
              {user.name} · <span className="capitalize">{user.role}</span>
            </span>
            <button
              onClick={handleLogout}
              className="rounded-md border border-slate-200 px-3 py-1.5 text-sm font-medium text-ink hover:bg-slate-50"
            >
              Logout
            </button>
          </div>
        </header>

        <nav className="flex gap-1 overflow-x-auto border-b border-slate-200 bg-white px-2 py-2 md:hidden">
          {items.map((n) => {
            const active = pathname === n.href;
            return (
              <Link
                key={n.href}
                href={n.href}
                className={`whitespace-nowrap rounded-md px-3 py-1.5 text-sm ${
                  active
                    ? "bg-brand-blue text-white"
                    : "text-muted hover:bg-slate-100"
                }`}
              >
                {n.label}
              </Link>
            );
          })}
        </nav>

        <main className="flex-1 p-4 md:p-6">{children}</main>
      </div>
    </div>
  );
}
