//
//  EntryDetailView.swift
//  summer-homework-diary
//

import SwiftUI

struct DiaryDetailScreen: View {
    let entry: DiaryEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(entry.date, style: .date)
                    .font(.diaryCaption)
                    .foregroundStyle(.secondary)

                Text(entry.text)
                    .font(.diaryBody)

                Divider()

                Text("피드백")
                    .font(.diaryCaption)

                Text(entry.feedback ?? "")
                    .font(.diaryComment)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        DiaryDetailScreen(
            entry: DiaryEntry(
                date: .now,
                text: "오늘은 도서관에서 책을 읽었다.",
                feedback: "꾸준히 독서하는 습관이 정말 멋져요!"
            )
        )
    }
}
