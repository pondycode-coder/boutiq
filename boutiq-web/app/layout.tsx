import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Boutiq",
  description:
    "Boutiq - point of sale and inventory management for retail businesses.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
