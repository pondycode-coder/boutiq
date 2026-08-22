"use client";

import { useEffect, useMemo, useState } from "react";
import { supabase } from "@/lib/supabase";
import { getSession } from "@/lib/auth";
import { formatXaf } from "@/lib/format";
import { VAT_RATE } from "@/lib/constants";
import type { AppUser, Client, Product } from "@/lib/types";

interface CartLine {
  product: Product;
  quantity: number;
}

const PAYMENT_METHODS = [
  { value: "cash", label: "Cash" },
  { value: "credit", label: "Pay Later" },
  { value: "mtn_momo", label: "MTN MoMo" },
  { value: "orange_money", label: "Orange Money" },
  { value: "bank_transfer", label: "Bank Transfer" },
];

export default function PosPage() {
  const [user, setUser] = useState<AppUser | null>(null);
  const [products, setProducts] = useState<Product[]>([]);
  const [clients, setClients] = useState<Client[]>([]);
  const [query, setQuery] = useState("");
  const [cart, setCart] = useState<CartLine[]>([]);
  const [payment, setPayment] = useState("cash");
  const [clientId, setClientId] = useState("");
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [done, setDone] = useState<string | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    setUser(getSession());
  }, []);

  useEffect(() => {
    (async () => {
      const [{ data: p }, { data: c }] = await Promise.all([
        supabase.from("products").select("*").eq("is_active", true).order("name"),
        supabase.from("clients").select("id, name").eq("is_active", true).order("name"),
      ]);
      setProducts((p ?? []) as Product[]);
      setClients((c ?? []) as Client[]);
      setLoading(false);
    })();
  }, []);

  const filteredProducts = useMemo(
    () =>
      products.filter((p) =>
        (p.name + " " + p.category).toLowerCase().includes(query.toLowerCase()),
      ),
    [products, query],
  );

  const totals = useMemo(() => {
    const subtotal = cart.reduce(
      (s, l) => s + l.product.price * l.quantity,
      0,
    );
    const vat = subtotal * VAT_RATE;
    return { subtotal, vat, total: subtotal + vat };
  }, [cart]);

  function addToCart(p: Product) {
    setCart((prev) => {
      const found = prev.find((l) => l.product.id === p.id);
      if (found) {
        return prev.map((l) =>
          l.product.id === p.id ? { ...l, quantity: l.quantity + 1 } : l,
        );
      }
      return [...prev, { product: p, quantity: 1 }];
    });
  }

  function setQty(id: string, qty: number) {
    if (qty <= 0) {
      setCart((prev) => prev.filter((l) => l.product.id !== id));
      return;
    }
    setCart((prev) =>
      prev.map((l) => (l.product.id === id ? { ...l, quantity: qty } : l)),
    );
  }

  async function charge() {
    setError("");
    if (cart.length === 0) return;
    if (payment === "credit" && !clientId) {
      setError("Select a client for credit sale.");
      return;
    }
    setBusy(true);
    const orderId = crypto.randomUUID();
    const now = new Date().toISOString();
    const isCredit = payment === "credit";
    const orderPayload = {
      id: orderId,
      store_id: "",
      vendor_id: "",
      status: isCredit ? "pending" : "paid",
      payment_method: payment,
      payment_status: isCredit ? "pending" : "paid",
      subtotal: totals.subtotal,
      vat_amount: totals.vat,
      total_amount: totals.total,
      client_id: clientId || null,
      salesperson_id: user?.id ?? null,
      confirmed_at: isCredit ? null : now,
      created_at: now,
    };

    const { error: orderErr } = await supabase
      .from("orders")
      .insert(orderPayload);
    if (orderErr) {
      setBusy(false);
      setError(orderErr.message);
      return;
    }

    const items = cart.map((l) => ({
      id: crypto.randomUUID(),
      order_id: orderId,
      product_id: l.product.id,
      vendor_id: "",
      quantity: l.quantity,
      unit_price: l.product.price,
      vat_rate: VAT_RATE,
      line_subtotal: l.product.price * l.quantity,
      line_vat_amount: l.product.price * l.quantity * VAT_RATE,
      line_total: l.product.price * l.quantity * (1 + VAT_RATE),
    }));
    const { error: itemsErr } = await supabase
      .from("order_items")
      .insert(items);
    if (itemsErr) {
      setBusy(false);
      setError(itemsErr.message);
      return;
    }

    if (payment === "cash") {
      const { error: payErr } = await supabase.from("cash_payments").insert({
        id: crypto.randomUUID(),
        order_id: orderId,
        store_id: "",
        client_id: clientId || null,
        salesperson_id: user?.id ?? null,
        amount_tendered: totals.total,
        change_amount: 0,
        paid_at: now,
      });
      if (payErr) {
        setBusy(false);
        setError(payErr.message);
        return;
      }
    }

    setBusy(false);
    setDone(orderId.slice(0, 8));
    setCart([]);
    setClientId("");
  }

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-bold text-ink">POS</h1>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
        <div className="lg:col-span-2 space-y-3">
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search products to sell…"
            className="w-full rounded-md border border-slate-300 px-4 py-2 text-sm outline-none focus:border-brand-blue"
          />
          {loading ? (
            <p className="text-muted">Loading…</p>
          ) : (
            <div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
              {filteredProducts.map((p) => (
                <button
                  key={p.id}
                  onClick={() => addToCart(p)}
                  className="rounded-lg border border-slate-200 bg-white p-3 text-left shadow-sm hover:border-brand-blue"
                >
                  <p className="text-sm font-semibold text-ink">{p.name}</p>
                  <p className="text-xs text-muted">{p.category || "—"}</p>
                  <p className="mt-1 text-sm font-bold text-brand-blue">
                    {formatXaf(p.price)}
                  </p>
                </button>
              ))}
              {filteredProducts.length === 0 && (
                <p className="col-span-full text-sm text-muted">
                  No products.
                </p>
              )}
            </div>
          )}
        </div>

        <div className="rounded-lg border border-slate-200 bg-white p-4 shadow-sm">
          <h2 className="mb-3 text-sm font-semibold text-ink">Cart</h2>
          {cart.length === 0 ? (
            <p className="text-sm text-muted">Cart is empty.</p>
          ) : (
            <div className="space-y-2">
              {cart.map((l) => (
                <div
                  key={l.product.id}
                  className="flex items-center justify-between gap-2 border-b border-slate-100 pb-2"
                >
                  <div className="min-w-0">
                    <p className="truncate text-sm font-medium text-ink">
                      {l.product.name}
                    </p>
                    <p className="text-xs text-muted">
                      {formatXaf(l.product.price)}
                    </p>
                  </div>
                  <div className="flex items-center gap-1">
                    <button
                      onClick={() => setQty(l.product.id, l.quantity - 1)}
                      className="h-7 w-7 rounded border border-slate-200 text-ink"
                    >
                      −
                    </button>
                    <span className="w-8 text-center text-sm">{l.quantity}</span>
                    <button
                      onClick={() => setQty(l.product.id, l.quantity + 1)}
                      className="h-7 w-7 rounded border border-slate-200 text-ink"
                    >
                      +
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}

          <div className="mt-3 space-y-1 border-t border-slate-100 pt-3 text-sm">
            <Row label="Subtotal" value={formatXaf(totals.subtotal)} />
            <Row label="VAT (19.25%)" value={formatXaf(totals.vat)} />
            <Row
              label="Total"
              value={formatXaf(totals.total)}
              bold
            />
          </div>

          <div className="mt-3 space-y-2">
            <select
              value={payment}
              onChange={(e) => setPayment(e.target.value)}
              className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
            >
              {PAYMENT_METHODS.map((m) => (
                <option key={m.value} value={m.value}>
                  {m.label}
                </option>
              ))}
            </select>
            {payment === "credit" && (
              <select
                value={clientId}
                onChange={(e) => setClientId(e.target.value)}
                className="w-full rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
              >
                <option value="">Select client…</option>
                {clients.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.name}
                  </option>
                ))}
              </select>
            )}
            {error && <p className="text-sm text-red-600">{error}</p>}
            <button
              onClick={charge}
              disabled={busy || cart.length === 0}
              className="w-full rounded-md bg-brand-blue py-3 text-sm font-semibold text-white hover:bg-brand-navy disabled:opacity-60"
            >
              {busy ? "Processing…" : "Charge"}
            </button>
            {done && (
              <p className="text-center text-sm font-medium text-emerald-600">
                Sale recorded: #{done}
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

function Row({
  label,
  value,
  bold,
}: {
  label: string;
  value: string;
  bold?: boolean;
}) {
  return (
    <div className="flex justify-between">
      <span className="text-muted">{label}</span>
      <span className={bold ? "font-bold text-ink" : "text-ink"}>{value}</span>
    </div>
  );
}
