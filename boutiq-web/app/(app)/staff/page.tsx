"use client";

import { useEffect, useState } from "react";
import { supabase } from "@/lib/supabase";
import type { AppUser, UserRole } from "@/lib/types";

interface StaffRow extends AppUser {
  phone?: string;
  email?: string | null;
  pin?: string;
  is_active?: boolean;
}

// The `users` table row has more columns; we manage the fields relevant to login/roles.
interface StaffForm {
  id: string;
  name: string;
  phone: string;
  email: string;
  pin: string;
  role: UserRole;
  is_active: boolean;
}

const emptyForm: StaffForm = {
  id: "",
  name: "",
  phone: "",
  email: "",
  pin: "",
  role: "salesperson",
  is_active: true,
};

export default function StaffPage() {
  const [staff, setStaff] = useState<StaffRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState("");
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState<StaffForm>(emptyForm);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  async function load() {
    setLoading(true);
    const { data } = await supabase
      .from("users")
      .select("id, name, phone, email, pin, role, is_active")
      .order("name", { ascending: true });
    setStaff((data ?? []) as StaffRow[]);
    setLoading(false);
  }

  useEffect(() => {
    load();
  }, []);

  function openAdd() {
    setForm(emptyForm);
    setError("");
    setShowForm(true);
  }

  function openEdit(s: StaffRow) {
    setForm({
      id: s.id,
      name: s.name,
      phone: s.phone ?? "",
      email: s.email ?? "",
      pin: s.pin ?? "",
      role: (s.role as UserRole) ?? "salesperson",
      is_active: s.is_active ?? true,
    });
    setError("");
    setShowForm(true);
  }

  async function save() {
    setError("");
    if (!form.name.trim()) {
      setError("Name is required.");
      return;
    }
    if (!form.pin.trim()) {
      setError("PIN is required (used to log in).");
      return;
    }
    setSaving(true);
    const payload = {
      name: form.name.trim(),
      phone: form.phone.trim(),
      email: form.email.trim() || null,
      pin: form.pin.trim(),
      role: form.role,
      is_active: form.is_active,
    };
    let res;
    if (form.id) {
      res = await supabase.from("users").update(payload).eq("id", form.id);
    } else {
      res = await supabase
        .from("users")
        .insert({ ...payload, id: crypto.randomUUID() });
    }
    setSaving(false);
    if (res.error) {
      setError(res.error.message);
      return;
    }
    setShowForm(false);
    load();
  }

  async function remove(id: string) {
    if (!confirm("Delete this staff member? They will no longer be able to log in."))
      return;
    await supabase.from("users").delete().eq("id", id);
    load();
  }

  const filtered = staff.filter((s) =>
    (s.name + " " + (s.phone ?? "")).toLowerCase().includes(query.toLowerCase()),
  );

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-ink">Staff</h1>
        <button
          onClick={openAdd}
          className="rounded-md bg-brand-blue px-4 py-2 text-sm font-semibold text-white hover:bg-brand-navy"
        >
          + Add Staff
        </button>
      </div>

      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search staff…"
        className="w-full rounded-md border border-slate-300 px-4 py-2 text-sm outline-none focus:border-brand-blue"
      />

      {loading ? (
        <p className="text-muted">Loading…</p>
      ) : (
        <div className="overflow-x-auto rounded-lg border border-slate-200 bg-white shadow-sm">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-left text-muted">
              <tr>
                <th className="px-4 py-3 font-medium">Name</th>
                <th className="px-4 py-3 font-medium">Phone</th>
                <th className="px-4 py-3 font-medium">Role</th>
                <th className="px-4 py-3 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((s) => (
                <tr key={s.id} className="border-t border-slate-100">
                  <td className="px-4 py-3 font-medium text-ink">{s.name}</td>
                  <td className="px-4 py-3 text-muted">{s.phone || "—"}</td>
                  <td className="px-4 py-3">
                    <span
                      className={`rounded-full px-2 py-1 text-xs font-medium capitalize ${
                        s.role === "admin"
                          ? "bg-brand-blue/10 text-brand-blue"
                          : "bg-slate-100 text-slate-600"
                      }`}
                    >
                      {s.role}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-right">
                    <button
                      onClick={() => openEdit(s)}
                      className="text-brand-blue hover:underline"
                    >
                      Edit
                    </button>
                    <button
                      onClick={() => remove(s.id)}
                      className="ml-3 text-red-600 hover:underline"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
              {filtered.length === 0 && (
                <tr>
                  <td colSpan={4} className="px-4 py-6 text-center text-muted">
                    No staff found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}

      {showForm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
          <div className="w-full max-w-md rounded-lg bg-white p-6 shadow-lg">
            <h2 className="mb-4 text-lg font-bold text-ink">
              {form.id ? "Edit Staff" : "Add Staff"}
            </h2>
            <div className="space-y-3">
              <Field label="Name">
                <input
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                  className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                />
              </Field>
              <Field label="PIN (login code)">
                <input
                  value={form.pin}
                  onChange={(e) => setForm({ ...form, pin: e.target.value })}
                  className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm tracking-widest outline-none focus:border-brand-blue"
                />
              </Field>
              <Field label="Role">
                <select
                  value={form.role}
                  onChange={(e) =>
                    setForm({ ...form, role: e.target.value as UserRole })
                  }
                  className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                >
                  <option value="salesperson">Salesperson</option>
                  <option value="admin">Admin</option>
                </select>
              </Field>
              <div className="grid grid-cols-2 gap-3">
                <Field label="Phone">
                  <input
                    value={form.phone}
                    onChange={(e) =>
                      setForm({ ...form, phone: e.target.value })
                    }
                    className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                  />
                </Field>
                <Field label="Email">
                  <input
                    value={form.email}
                    onChange={(e) =>
                      setForm({ ...form, email: e.target.value })
                    }
                    className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                  />
                </Field>
              </div>
              <label className="flex items-center gap-2 text-sm text-ink">
                <input
                  type="checkbox"
                  checked={form.is_active}
                  onChange={(e) =>
                    setForm({ ...form, is_active: e.target.checked })
                  }
                />
                Active
              </label>
            </div>
            {error && <p className="mt-3 text-sm text-red-600">{error}</p>}
            <div className="mt-5 flex justify-end gap-2">
              <button
                onClick={() => setShowForm(false)}
                className="rounded-md border border-slate-200 px-4 py-2 text-sm font-medium hover:bg-slate-50"
              >
                Cancel
              </button>
              <button
                onClick={save}
                disabled={saving}
                className="rounded-md bg-brand-blue px-4 py-2 text-sm font-semibold text-white hover:bg-brand-navy disabled:opacity-60"
              >
                {saving ? "Saving…" : "Save"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function Field({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <label className="block">
      <span className="mb-1 block text-xs font-medium text-muted">
        {label}
      </span>
      {children}
    </label>
  );
}
