"use client";

import { useEffect, useState } from "react";
import { supabase } from "@/lib/supabase";
import { formatXaf } from "@/lib/format";
import type { Client, OrderRow, AppUser } from "@/lib/types";

const STATUS_OPTIONS = [
  "all",
  "paid",
  "pending",
  "partial",
  "cancelled",
  "preparing",
  "ready",
  "delivered",
];

const statusColor: Record<string, string> = {
  paid: "bg-emerald-500/10 text-emerald-600",
  pending: "bg-amber-500/10 text-amber-600",
  partial: "bg-amber-500/10 text-amber-600",
  cancelled: "bg-red-500/10 text-red-600",
  preparing: "bg-blue-500/10 text-blue-600",
  ready: "bg-indigo-500/10 text-indigo-600",
  delivered: "bg-emerald-500/10 text-emerald-600",
};

export default function OrdersPage() {
  const [orders, setOrders] = useState<OrderRow[]>([]);
  const [users, setUsers] = useState<Record<string, string>>({});
  const [clients, setClients] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(true);
  const [status, setStatus] = useState("all");
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");
  const [query, setQuery] = useState("");

  async function load() {
    setLoading(true);
    const [{ data: o }, { data: u }, { data: c }] = await Promise.all([
      supabase.from("orders").select("*").order("created_at", { ascending: false }),
      supabase.from("users").select("id, name"),
      supabase.from("clients").select("id, name"),
    ]);
    setOrders((o ?? []) as OrderRow[]);
    setUsers(
      Object.fromEntries(((u ?? []) as AppUser[]).map((x) => [x.id, x.name])),
    );
    setClients(
      Object.fromEntries(((c ?? []) as Client[]).map((x) => [x.id, x.name])),
    );
    setLoading(false);
  }

  useEffect(() => {
    load();
  }, []);

  const filtered = orders.filter((o) => {
    if (status !== "all" && o.status !== status) return false;
    if (from && o.created_at < from + "T00:00:00") return false;
    if (to && o.created_at > to + "T23:59:59") return false;
    if (query && !o.id.toLowerCase().includes(query.toLowerCase())) return false;
    return true;
  });

  const totalSales = filtered
    .filter((o) => o.payment_status === "paid")
    .reduce((s, o) => s + (o.total_amount || 0), 0);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-ink">Orders</h1>
        <span className="text-sm text-muted">
          Filtered total: <strong className="text-ink">{formatXaf(totalSales)}</strong>
        </span>
      </div>

      <div className="flex flex-wrap gap-2">
        <select
          value={status}
          onChange={(e) => setStatus(e.target.value)}
          className="rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
        >
          {STATUS_OPTIONS.map((s) => (
            <option key={s} value={s}>
              {s === "all" ? "All statuses" : s[0].toUpperCase() + s.slice(1)}
            </option>
          ))}
        </select>
        <input
          type="date"
          value={from}
          onChange={(e) => setFrom(e.target.value)}
          className="rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
        />
        <input
          type="date"
          value={to}
          onChange={(e) => setTo(e.target.value)}
          className="rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
        />
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search order id…"
          className="flex-1 rounded-md border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-blue"
        />
      </div>

      {loading ? (
        <p className="text-muted">Loading…</p>
      ) : (
        <div className="overflow-x-auto rounded-lg border border-slate-200 bg-white shadow-sm">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-left text-muted">
              <tr>
                <th className="px-4 py-3 font-medium">Order</th>
                <th className="px-4 py-3 font-medium">Date</th>
                <th className="px-4 py-3 font-medium">Client</th>
                <th className="px-4 py-3 font-medium">Salesperson</th>
                <th className="px-4 py-3 font-medium text-right">Total</th>
                <th className="px-4 py-3 font-medium">Status</th>
                <th className="px-4 py-3 font-medium">Payment</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((o) => (
                <tr key={o.id} className="border-t border-slate-100">
                  <td className="px-4 py-3 font-mono text-xs text-ink">
                    {o.id.slice(0, 8)}
                  </td>
                  <td className="px-4 py-3 text-muted">
                    {new Date(o.created_at).toLocaleString()}
                  </td>
                  <td className="px-4 py-3 text-ink">
                    {o.client_id ? clients[o.client_id] ?? "—" : "—"}
                  </td>
                  <td className="px-4 py-3 text-muted">
                    {o.salesperson_id ? users[o.salesperson_id] ?? "—" : "—"}
                  </td>
                  <td className="px-4 py-3 text-right font-medium text-ink">
                    {formatXaf(o.total_amount)}
                  </td>
                  <td className="px-4 py-3">
                    <span
                      className={`rounded-full px-2 py-1 text-xs font-medium capitalize ${
                        statusColor[o.status] ?? "bg-slate-100 text-slate-600"
                      }`}
                    >
                      {o.status}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-muted">{o.payment_method}</td>
                </tr>
              ))}
              {filtered.length === 0 && (
                <tr>
                  <td colSpan={7} className="px-4 py-6 text-center text-muted">
                    No orders found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
