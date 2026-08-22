interface Bar {
  label: string;
  value: number;
}

interface SimpleBarChartProps {
  data: Bar[];
  format?: (v: number) => string;
  color?: string;
  height?: number;
}

export default function SimpleBarChart({
  data,
  format = (v) => String(v),
  color = "#0077B6",
  height = 160,
}: SimpleBarChartProps) {
  const max = Math.max(1, ...data.map((d) => d.value));
  return (
    <div className="flex items-end gap-2" style={{ height }}>
      {data.map((d, i) => {
        const pct = (d.value / max) * 100;
        return (
          <div key={i} className="flex flex-1 flex-col items-center gap-1">
            <div className="flex w-full flex-1 items-end">
              <div
                className="w-full rounded-t-md transition-all"
                style={{
                  height: `${pct}%`,
                  background: color,
                  minHeight: d.value > 0 ? 4 : 0,
                }}
                title={`${d.label}: ${format(d.value)}`}
              />
            </div>
            <span className="text-[10px] text-muted">{d.label}</span>
          </div>
        );
      })}
    </div>
  );
}
