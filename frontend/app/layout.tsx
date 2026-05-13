import "./globals.css";
import type { Metadata } from "next";
import Link from "next/link";
import type { ReactNode } from "react";

export const metadata: Metadata = {
  title: "Provably Fair On-Chain GameHub",
  description: "SC6107 Option 4 project frontend"
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <div className="container">
          <header className="card">
            <h1>Provably Fair On-Chain GameHub</h1>
            <p className="muted">SC6107 Option 4 Final Submission Build</p>
            <nav>
              <Link href="/">Dashboard</Link> | <Link href="/raffle">Raffle</Link> |{" "}
              <Link href="/dice">Dice</Link>
            </nav>
          </header>
          {children}
        </div>
      </body>
    </html>
  );
}
