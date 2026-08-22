import type { ReactNode } from "react";

interface KpiCardProps {
  label: string;
  value: string;
  icon: ReactNode;
  tone?: "blue" | "gold" | "green";
}

const toneClasses: Record<string, string> = {
  blue: "bg-brand-blue/10 text-brand-blue",
  gold: "bg-brand-gold/10 text-brand-gold",
  green: "bg-emerald-500/10 text-emerald-600",
};

export default function KpiCard({
  label,
  value,
  icon,
  tone = "blue",
}: KpiCardProps) {
  return (
    <div className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm font-medium text-muted">{label}</p>
          <p className="mt-2 text-2xl font-bold text-ink">{value}</p>
        </div>
        <div
          className={`flex h-11 w-11 items-center justify-center rounded-lg ${
            toneClasses[tone]
          }`}
        >
          {icon}
        </div>
      </div>
    </div>
  );
}
