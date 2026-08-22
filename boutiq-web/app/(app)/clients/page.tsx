"use client";

import { useEffect, useState } from "react";
import { supabase } from "@/lib/supabase";
import type { Client } from "@/lib/types";

const CLIENT_TYPES = ["retail", "wholesale", "corporate"];

interface ClientForm {
  id: string;
  name: string;
  name_fr: string;
  client_type: string;
  phone: string;
  email: string;
  region: string;
  address: string;
  credit_limit: number;
  current_balance: number;
  is_active: boolean;
}

const emptyForm: ClientForm = {
  id: "",
  name: "",
  name_fr: "",
  client_type: "retail",
  phone: "",
  email: "",
  region: "",
  address: "",
  credit_limit: 0,
  current_balance: 0,
  is_active: true,
};

export default function ClientsPage() {
  const [clients, setClients] = useState<Client[]>([]);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState("");
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState<ClientForm>(emptyForm);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  async function load() {
    setLoading(true);
    const { data } = await supabase
      .from("clients")
      .select("*")
      .order("name", { ascending: true });
    setClients((data ?? []) as Client[]);
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

  function openEdit(c: Client) {
    setForm({
      id: c.id,
      name: c.name,
      name_fr: c.name_fr,
      client_type: c.client_type || "retail",
      phone: c.phone,
      email: c.email ?? "",
      region: c.region,
      address: c.address,
      credit_limit: c.credit_limit,
      current_balance: c.current_balance,
      is_active: c.is_active,
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
    setSaving(true);
    const payload = {
      name: form.name.trim(),
      name_fr: form.name_fr.trim(),
      client_type: form.client_type,
      phone: form.phone.trim(),
      email: form.email.trim() || null,
      region: form.region.trim(),
      address: form.address.trim(),
      credit_limit: Number(form.credit_limit) || 0,
      current_balance: Number(form.current_balance) || 0,
      is_active: form.is_active,
    };
    let res;
    if (form.id) {
      res = await supabase.from("clients").update(payload).eq("id", form.id);
    } else {
      res = await supabase
        .from("clients")
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
    if (!confirm("Delete this client?")) return;
    await supabase.from("clients").delete().eq("id", id);
    load();
  }

  const filtered = clients.filter((c) =>
    (c.name + " " + c.phone).toLowerCase().includes(query.toLowerCase()),
  );

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-ink">Clients</h1>
        <button
          onClick={openAdd}
          className="rounded-md bg-brand-blue px-4 py-2 text-sm font-semibold text-white hover:bg-brand-navy"
        >
          + Add Client
        </button>
      </div>

      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search clients…"
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
                <th className="px-4 py-3 font-medium">Type</th>
                <th className="px-4 py-3 font-medium">Phone</th>
                <th className="px-4 py-3 font-medium text-right">Balance</th>
                <th className="px-4 py-3 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((c) => (
                <tr key={c.id} className="border-t border-slate-100">
                  <td className="px-4 py-3 font-medium text-ink">{c.name}</td>
                  <td className="px-4 py-3 capitalize text-muted">
                    {c.client_type || "—"}
                  </td>
                  <td className="px-4 py-3 text-muted">{c.phone || "—"}</td>
                  <td className="px-4 py-3 text-right">
                    {c.current_balance.toLocaleString()}
                  </td>
                  <td className="px-4 py-3 text-right">
                    <button
                      onClick={() => openEdit(c)}
                      className="text-brand-blue hover:underline"
                    >
                      Edit
                    </button>
                    <button
                      onClick={() => remove(c.id)}
                      className="ml-3 text-red-600 hover:underline"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
              {filtered.length === 0 && (
                <tr>
                  <td colSpan={5} className="px-4 py-6 text-center text-muted">
                    No clients found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}

      {showForm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
          <div className="max-h-[90vh] w-full max-w-md overflow-y-auto rounded-lg bg-white p-6 shadow-lg">
            <h2 className="mb-4 text-lg font-bold text-ink">
              {form.id ? "Edit Client" : "Add Client"}
            </h2>
            <div className="space-y-3">
              <Field label="Name">
                <input
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                  className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                />
              </Field>
              <Field label="Name (French)">
                <input
                  value={form.name_fr}
                  onChange={(e) =>
                    setForm({ ...form, name_fr: e.target.value })
                  }
                  className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                />
              </Field>
              <Field label="Type">
                <select
                  value={form.client_type}
                  onChange={(e) =>
                    setForm({ ...form, client_type: e.target.value })
                  }
                  className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                >
                  {CLIENT_TYPES.map((t) => (
                    <option key={t} value={t}>
                      {t[0].toUpperCase() + t.slice(1)}
                    </option>
                  ))}
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
              <Field label="Region">
                <input
                  value={form.region}
                  onChange={(e) =>
                    setForm({ ...form, region: e.target.value })
                  }
                  className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                />
              </Field>
              <Field label="Address">
                <input
                  value={form.address}
                  onChange={(e) =>
                    setForm({ ...form, address: e.target.value })
                  }
                  className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                />
              </Field>
              <div className="grid grid-cols-2 gap-3">
                <Field label="Credit Limit">
                  <input
                    type="number"
                    value={form.credit_limit}
                    onChange={(e) =>
                      setForm({
                        ...form,
                        credit_limit: Number(e.target.value),
                      })
                    }
                    className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                  />
                </Field>
                <Field label="Current Balance">
                  <input
                    type="number"
                    value={form.current_balance}
                    onChange={(e) =>
                      setForm({
                        ...form,
                        current_balance: Number(e.target.value),
                      })
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
