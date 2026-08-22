export function formatXaf(value: number): string {
  const rounded = Math.round(value);
  return (
    "XAF " +
    rounded.toLocaleString("en-US", { maximumFractionDigits: 0 })
  );
}

export function formatNumber(value: number): string {
  return value.toLocaleString("en-US", { maximumFractionDigits: 0 });
}

export function shortDay(index: number): string {
  const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  return days[index % 7];
}
