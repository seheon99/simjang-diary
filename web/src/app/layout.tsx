import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "심장",
  description: "심장의 자세한 정보를 서빙하기 위한 페이지",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko" className={`h-full antialiased`}>
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
