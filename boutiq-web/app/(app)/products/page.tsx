"use client";

import { useEffect, useState } from "react";
import { supabase } from "@/lib/supabase";
import { formatXaf, formatNumber } from "@/lib/format";
import { LOW_STOCK_THRESHOLD } from "@/lib/constants";
import type { Product } from "@/lib/types";

interface ProductFormState {
  id: string;
  name: string;
  category: string;
  price: number;
  unit: string;
  description: string;
  stock_quantity: number;
  is_active: boolean;
}

const emptyForm: ProductFormState = {
  id: "",
  name: "",
  category: "",
  price: 0,
  unit: "",
  description: "",
  stock_quantity: 0,
  is_active: true,
};

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState("");
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState<ProductFormState>(emptyForm);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  async function load() {
    setLoading(true);
    const { data } = await supabase
      .from("products")
      .select("*")
      .order("name", { ascending: true });
    setProducts((data ?? []) as Product[]);
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

  function openEdit(p: Product) {
    setForm({
      id: p.id,
      name: p.name,
      category: p.category,
      price: p.price,
      unit: p.unit,
      description: p.description ?? "",
      stock_quantity: p.stock_quantity,
      is_active: p.is_active,
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
      category: form.category.trim(),
      price: Number(form.price) || 0,
      unit: form.unit.trim(),
      description: form.description.trim() || null,
      stock_quantity: Number(form.stock_quantity) || 0,
      is_active: form.is_active,
    };
    let res;
    if (form.id) {
      res = await supabase.from("products").update(payload).eq("id", form.id);
    } else {
      res = await supabase
        .from("products")
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
    if (!confirm("Delete this product?")) return;
    await supabase.from("products").delete().eq("id", id);
    load();
  }

  const filtered = products.filter((p) =>
    (p.name + " " + p.category).toLowerCase().includes(query.toLowerCase()),
  );

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-ink">Products</h1>
        <button
          onClick={openAdd}
          className="rounded-md bg-brand-blue px-4 py-2 text-sm font-semibold text-white hover:bg-brand-navy"
        >
          + Add Product
        </button>
      </div>

      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search products…"
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
                <th className="px-4 py-3 font-medium">Category</th>
                <th className="px-4 py-3 font-medium text-right">Price</th>
                <th className="px-4 py-3 font-medium text-right">Stock</th>
                <th className="px-4 py-3 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((p) => (
                <tr key={p.id} className="border-t border-slate-100">
                  <td className="px-4 py-3 font-medium text-ink">{p.name}</td>
                  <td className="px-4 py-3 text-muted">{p.category || "—"}</td>
                  <td className="px-4 py-3 text-right">
                    {formatXaf(p.price)}
                  </td>
                  <td
                    className={`px-4 py-3 text-right ${
                      p.stock_quantity < LOW_STOCK_THRESHOLD
                        ? "font-semibold text-brand-gold"
                        : ""
                    }`}
                  >
                    {formatNumber(p.stock_quantity)}
                  </td>
                  <td className="px-4 py-3 text-right">
                    <button
                      onClick={() => openEdit(p)}
                      className="text-brand-blue hover:underline"
                    >
                      Edit
                    </button>
                    <button
                      onClick={() => remove(p.id)}
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
                    No products found.
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
              {form.id ? "Edit Product" : "Add Product"}
            </h2>
            <div className="space-y-3">
              <Field label="Name">
                <input
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                  className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                />
              </Field>
              <Field label="Category">
                <input
                  value={form.category}
                  onChange={(e) =>
                    setForm({ ...form, category: e.target.value })
                  }
                  className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                />
              </Field>
              <div className="grid grid-cols-2 gap-3">
                <Field label="Price (XAF)">
                  <input
                    type="number"
                    value={form.price}
                    onChange={(e) =>
                      setForm({ ...form, price: Number(e.target.value) })
                    }
                    className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                  />
                </Field>
                <Field label="Stock">
                  <input
                    type="number"
                    value={form.stock_quantity}
                    onChange={(e) =>
                      setForm({
                        ...form,
                        stock_quantity: Number(e.target.value),
                      })
                    }
                    className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                  />
                </Field>
              </div>
              <Field label="Unit">
                <input
                  value={form.unit}
                  onChange={(e) => setForm({ ...form, unit: e.target.value })}
                  className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                />
              </Field>
              <Field label="Description">
                <textarea
                  value={form.description}
                  onChange={(e) =>
                    setForm({ ...form, description: e.target.value })
                  }
                  rows={2}
                  className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
                />
              </Field>
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
