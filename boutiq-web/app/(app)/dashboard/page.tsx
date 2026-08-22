"use client";

import { useEffect, useState } from "react";
import { supabase } from "@/lib/supabase";
import { getSession, isAdmin } from "@/lib/auth";
import { formatXaf, formatNumber, shortDay } from "@/lib/format";
import KpiCard from "@/components/KpiCard";
import SimpleBarChart from "@/components/SimpleBarChart";
import type { AppUser, OrderRow, Product } from "@/lib/types";

const LOW_STOCK_THRESHOLD = 10;

export default function DashboardPage() {
  const [user, setUser] = useState<AppUser | null>(null);
  const [loading, setLoading] = useState(true);
  const [salesToday, setSalesToday] = useState(0);
  const [ordersToday, setOrdersToday] = useState(0);
  const [lowStock, setLowStock] = useState(0);
  const [weekly, setWeekly] = useState<{ label: string; value: number }[]>([]);

  useEffect(() => {
    setUser(getSession());
  }, []);

  useEffect(() => {
    if (!user) return;
    (async () => {
      const startOfToday = new Date();
      startOfToday.setHours(0, 0, 0, 0);
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);
      sevenDaysAgo.setHours(0, 0, 0, 0);

      const [ordersRes, productsRes] = await Promise.all([
        supabase
          .from("orders")
          .select("id, total_amount, payment_status, created_at")
          .gte("created_at", sevenDaysAgo.toISOString()),
        supabase.from("products").select("id, stock_quantity"),
      ]);

      const orders = (ordersRes.data ?? []) as OrderRow[];
      const products = (productsRes.data ?? []) as Product[];

      const todays = orders.filter(
        (o) =>
          new Date(o.created_at) >= startOfToday &&
          o.payment_status === "paid",
      );
      setSalesToday(
        todays.reduce((s, o) => s + (o.total_amount || 0), 0),
      );
      setOrdersToday(todays.length);
      setLowStock(
        products.filter((p) => (p.stock_quantity ?? 0) < LOW_STOCK_THRESHOLD)
          .length,
      );

      const buckets: { label: string; value: number }[] = [];
      for (let i = 0; i < 7; i++) {
        const day = new Date(startOfToday);
        day.setDate(day.getDate() - (6 - i));
        const dayStart = new Date(day);
        const dayEnd = new Date(day);
        dayEnd.setHours(23, 59, 59, 999);
        const total = orders
          .filter((o) => {
            const d = new Date(o.created_at);
            return d >= dayStart && d <= dayEnd && o.payment_status === "paid";
          })
          .reduce((s, o) => s + (o.total_amount || 0), 0);
        buckets.push({ label: shortDay(day.getDay()), value: total });
      }
      setWeekly(buckets);
      setLoading(false);
    })();
  }, [user]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-ink">Dashboard</h1>
        <p className="text-sm text-muted">
          Welcome back{user ? `, ${user.name}` : ""}
        </p>
      </div>

      {loading ? (
        <p className="text-muted">Loading…</p>
      ) : (
        <>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
            <KpiCard
              label="Sales Today"
              value={formatXaf(salesToday)}
              tone="blue"
              icon={<span className="text-lg">₣</span>}
            />
            <KpiCard
              label="Orders Today"
              value={formatNumber(ordersToday)}
              tone="green"
              icon={<span className="text-lg">▥</span>}
            />
            <KpiCard
              label="Low Stock"
              value={formatNumber(lowStock)}
              tone="gold"
              icon={<span className="text-lg">▤</span>}
            />
          </div>

          <div className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
            <h2 className="mb-4 text-sm font-semibold text-ink">
              Sales — last 7 days
            </h2>
            <SimpleBarChart data={weekly} format={formatXaf} />
          </div>

          {isAdmin(user) && (
            <p className="text-xs text-muted">
              You have admin access: manage products, clients, and staff from
              the sidebar.
            </p>
          )}
        </>
      )}
    </div>
  );
}
