import type { Metadata } from "next";
import Link from "next/link";
import { Mail, ShieldCheck } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { Separator } from "@/components/ui/separator";

export const metadata: Metadata = {
  title: "지원 | 심장",
  description: "심장 앱 이용 중 궁금한 점이나 문제를 해결할 수 있는 지원 페이지입니다.",
};

const SUPPORT_EMAIL = "support.diary@seheon.kr";

const qna: { question: string; answer: string }[] = [
  {
    question: "일기 내용이 외부 서버로 전송되나요?",
    answer:
      "아니요. 심장은 서버가 없는 온디바이스 앱입니다. 일기와 AI 코멘트는 모두 사용자의 기기 안에서만 처리되며 외부로 전송되지 않습니다.",
  },
  {
    question: "회원가입이나 로그인이 필요한가요?",
    answer: "필요하지 않습니다. 심장은 계정 없이 설치 즉시 사용할 수 있습니다.",
  },
  {
    question: "인터넷 연결이 없어도 AI 코멘트를 받을 수 있나요?",
    answer: "네. AI 코멘트는 기기에서 직접 생성되므로 인터넷 연결 없이도 동일하게 동작합니다.",
  },
  {
    question: "작성한 일기를 삭제하면 어떻게 되나요?",
    answer:
      "일기나 앱을 삭제하면 기기에 저장된 데이터도 함께 삭제됩니다. 심장은 별도의 서버에 사본을 보관하지 않습니다.",
  },
];

export default function SupportPage() {
  return (
    <main className="mx-auto flex w-full max-w-2xl flex-1 flex-col gap-6 px-4 py-12">
      <Card>
        <CardHeader>
          <CardTitle className="text-2xl">심장 지원</CardTitle>
          <p className="text-sm text-muted-foreground">
            이용 중 궁금한 점이나 문제가 있다면 아래 방법으로 도움을 받으실 수 있습니다.
          </p>
        </CardHeader>
        <CardContent className="flex flex-col gap-8">
          <section className="flex flex-col gap-3">
            <h2 className="text-base font-semibold">문의하기</h2>
            <Link
              href={`mailto:${SUPPORT_EMAIL}`}
              className="flex items-center gap-2 text-sm text-primary hover:underline"
            >
              <Mail className="size-4" />
              {SUPPORT_EMAIL}
            </Link>
          </section>

          <Separator />

          <section className="flex flex-col gap-3">
            <h2 className="text-base font-semibold">자주 묻는 질문</h2>
            <Accordion>
              {qna.map(({ question, answer }) => (
                <AccordionItem key={question} value={question}>
                  <AccordionTrigger>{question}</AccordionTrigger>
                  <AccordionContent>{answer}</AccordionContent>
                </AccordionItem>
              ))}
            </Accordion>
          </section>

          <Separator />

          <section className="flex flex-col gap-3">
            <h2 className="text-base font-semibold">개인정보 처리방침</h2>
            <Link
              href="/privacy"
              className="flex items-center gap-2 text-sm text-primary hover:underline"
            >
              <ShieldCheck className="size-4" />
              개인정보 처리방침 보기
            </Link>
          </section>

          <Separator />

          <section className="flex flex-col gap-1 text-sm text-muted-foreground">
            <h2 className="text-base font-semibold text-foreground">서비스 정보</h2>
            <p>이름: 심장</p>
            <p>개발자: 유세헌</p>
            <p>지원 이메일: {SUPPORT_EMAIL}</p>
          </section>
        </CardContent>
      </Card>
    </main>
  );
}
