import Link from "next/link";

export default function Home() {
  return (
    <main className="mx-auto flex w-full max-w-2xl flex-1 flex-col items-center justify-center gap-4 px-4 py-12 text-center">
      <h1 className="text-2xl font-semibold">심장</h1>
      <nav className="flex gap-4 text-sm text-primary">
        <Link href="/support" className="hover:underline">
          지원
        </Link>
        <Link href="/privacy" className="hover:underline">
          개인정보 처리방침
        </Link>
      </nav>
    </main>
  );
}
