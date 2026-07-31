//
//  EntryDetailView.swift
//  summer-homework-diary
//

import SwiftUI

struct EntryDetailView: View {
    let entry: DiaryEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(entry.text)
                    .font(.body)

                Divider()

                Text("피드백")
                    .font(.headline)

                Text(entry.feedback ?? "")
                    .font(.body)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("일기")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        EntryDetailView(
            entry: DiaryEntry(
                date: .now,
                text: "오늘은 도서관에서 책을 읽었다.",
                feedback: "꾸준히 독서하는 습관이 정말 멋져요!"
            )
        )
    }
}
