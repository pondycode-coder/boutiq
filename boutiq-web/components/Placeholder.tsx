export default function Placeholder({ title }: { title: string }) {
  return (
    <div className="space-y-2">
      <h1 className="text-2xl font-bold text-ink">{title}</h1>
      <p className="text-sm text-muted">This screen is coming in the next step.</p>
    </div>
  );
}
