import { supabase } from "./supabase";
import type { AppUser, UserRole } from "./types";

const SESSION_KEY = "boutiq_session";

export async function loginWithPin(pin: string): Promise<AppUser | null> {
  const clean = pin.trim();
  if (!clean) return null;

  const { data, error } = await supabase
    .from("users")
    .select("id, name, pin, role, is_active")
    .eq("pin", clean)
    .eq("is_active", true)
    .maybeSingle();

  if (error || !data) return null;

  const role = (data.role as UserRole) ?? "salesperson";
  const user: AppUser = {
    id: data.id as string,
    name: (data.name as string) || "User",
    role,
  };

  if (typeof window !== "undefined") {
    window.localStorage.setItem(SESSION_KEY, JSON.stringify(user));
  }
  return user;
}

export function getSession(): AppUser | null {
  if (typeof window === "undefined") return null;
  const raw = window.localStorage.getItem(SESSION_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as AppUser;
  } catch {
    return null;
  }
}

export function logout(): void {
  if (typeof window !== "undefined") {
    window.localStorage.removeItem(SESSION_KEY);
  }
}

export function isAdmin(user: AppUser | null): boolean {
  return user?.role === "admin";
}
