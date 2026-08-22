"use client";

export default function SettingsPage() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-ink">Settings</h1>

      <section className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
        <h2 className="mb-4 text-sm font-semibold text-ink">Support</h2>
        <div className="space-y-3">
          <a
            href="mailto:pondycode@gmail.com"
            className="flex items-center justify-between rounded-md border border-slate-100 px-4 py-3 text-sm hover:bg-slate-50"
          >
            <span className="text-muted">Email</span>
            <span className="font-medium text-brand-blue">
              pondycode@gmail.com
            </span>
          </a>
          <a
            href="tel:+237674667234"
            className="flex items-center justify-between rounded-md border border-slate-100 px-4 py-3 text-sm hover:bg-slate-50"
          >
            <span className="text-muted">Phone</span>
            <span className="font-medium text-brand-blue">
              +237 674 667 234
            </span>
          </a>
        </div>
      </section>

      <section className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
        <h2 className="mb-4 text-sm font-semibold text-ink">App Info</h2>
        <dl className="space-y-2 text-sm">
          <div className="flex justify-between">
            <dt className="text-muted">Version</dt>
            <dd className="font-medium">1.0.0</dd>
          </div>
          <div className="flex justify-between">
            <dt className="text-muted">Backend</dt>
            <dd className="font-medium">Supabase</dd>
          </div>
        </dl>
      </section>
    </div>
  );
}
