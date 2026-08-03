import type { Metadata } from "next";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";

export const metadata: Metadata = {
  title: "개인정보 처리방침 | 심장",
  description: "심장 앱의 개인정보 처리방침입니다.",
};

const sections: { title: string; body: string[] }[] = [
  {
    title: "1. 앱에서 수집하는 정보",
    body: [
      "심장은 앱 사용 과정에서 개인정보를 수집하지 않습니다.",
      "일기 내용, AI 코멘트, 기기 식별 정보 등 어떠한 데이터도 외부로 전송되거나 서버에 저장되지 않으며, 모든 처리는 사용자의 기기 안에서만 이루어집니다.",
      "심장은 회원가입이나 로그인을 요구하지 않으며, 광고 또는 사용자 추적 기능을 사용하지 않습니다.",
    ],
  },
  {
    title: "2. 일기와 AI 처리 방식",
    body: [
      "심장의 AI 코멘트 기능은 온디바이스(On-device) LLM을 통해 사용자의 기기에서 직접 실행됩니다.",
      "사용자가 작성한 일기는 AI 코멘트를 생성하기 위해 네트워크를 통해 외부로 전송되지 않으며, 인터넷 연결 없이도 동일하게 동작합니다.",
    ],
  },
  {
    title: "3. 데이터 보관과 삭제",
    body: [
      "일기와 AI 코멘트를 포함한 모든 데이터는 사용자의 기기에만 저장됩니다.",
      "사용자가 일기를 삭제하거나 앱을 삭제하면 해당 데이터도 함께 삭제되며, 심장은 별도의 서버에 사본을 보관하지 않습니다.",
    ],
  },
  {
    title: "4. 제3자 제공",
    body: [
      "심장은 광고 네트워크, 분석 도구를 포함한 어떠한 제3자에게도 사용자의 데이터를 제공하지 않습니다.",
    ],
  },
  {
    title: "5. 고객 지원 문의",
    body: [
      "사용자가 이메일로 고객 지원을 요청하는 경우, 이메일 주소, 문의 내용 및 사용자가 첨부한 정보가 문의 처리를 위해 전달될 수 있습니다. 해당 정보는 문의 응답과 문제 해결을 위해서만 사용하며, 문의 처리가 완료된 후 불필요하게 보관하지 않습니다.",
    ],
  },
  {
    title: "6. 개인정보 처리방침 변경",
    body: [
      "앱의 기능이나 데이터 처리 방식이 변경되는 경우 이 개인정보 처리방침도 함께 변경하며, 변경된 시행일을 이 페이지에 표시합니다.",
    ],
  },
  {
    title: "7. 문의",
    body: [
      "개인정보와 관련된 문의는 아래 이메일로 보내주세요.",
      "이메일: support.diary@seheon.kr",
      "운영자: 유세헌",
    ],
  },
];

export default function PrivacyPage() {
  return (
    <main className="mx-auto flex w-full max-w-2xl flex-1 flex-col gap-6 px-4 py-12">
      <Card>
        <CardHeader>
          <CardTitle className="text-2xl">심장 개인정보 처리방침</CardTitle>
          <p className="text-sm text-muted-foreground">시행일: 2026년 8월 3일</p>
        </CardHeader>
        <CardContent className="flex flex-col gap-6">
          <p className="text-sm leading-relaxed">
            심장은 사용자의 사적인 기록을 중요하게 생각합니다. 심장의 AI 기능은
            사용자의 기기에서 작동하며, 사용자가 작성한 일기와 생성된 AI
            코멘트는 외부 서버로 전송되지 않습니다.
          </p>
          <Separator />
          {sections.map(({ title, body }) => (
            <section key={title} className="flex flex-col gap-2">
              <h2 className="text-base font-semibold">{title}</h2>
              {body.map((paragraph) => (
                <p key={paragraph} className="text-sm leading-relaxed text-muted-foreground">
                  {paragraph}
                </p>
              ))}
            </section>
          ))}
        </CardContent>
      </Card>
    </main>
  );
}
