//
//  EntryDetailView.swift
//  summer-homework-diary
//

import SwiftUI
import SwiftData
import OSLog

struct DiaryDetailScreen: View {
    let entry: DiaryEntry

    @Environment(\.modelContext) private var modelContext

    @State private var isGenerating = false

    private let feedbackService = DiaryFeedbackService()
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "simjang",
        category: "Performance"
    )

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

                if let feedback = entry.feedback {
                    Text(feedback)
                        .font(.diaryComment)
                } else {
                    Button {
                        Task { await retryFeedback() }
                    } label: {
                        if isGenerating {
                            ProgressView()
                        } else {
                            Label("답글 다시 만들기", systemImage: "arrow.clockwise")
                        }
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(isGenerating)
                    .tint(.taupe700)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .statusBarHidden(true)
    }

    @MainActor
    private func retryFeedback() async {
        isGenerating = true
        defer { isGenerating = false }

        do {
            entry.feedback = try await feedbackService.generate(
                for: entry,
                includeSystemPrompt: true
            )
            try modelContext.save()
        } catch {
            logger.error("\(error.localizedDescription, privacy: .public)")
        }
    }
}

#Preview("Feedback") {
    NavigationStack {
        DiaryDetailScreen(
            entry: DiaryEntry(
                date: .now,
                text: "오늘은 도서관에서 책을 읽었다.",
                feedback: "꾸준히 독서하는 습관이 정말 멋져요!"
            )
        )
    }
    .modelContainer(for: DiaryEntry.self, inMemory: true)
}

#Preview("Pending feedback") {
    NavigationStack {
        DiaryDetailScreen(
            entry: DiaryEntry(
                date: .now,
                text: "오늘은 도서관에서 책을 읽었다."
            )
        )
    }
    .modelContainer(for: DiaryEntry.self, inMemory: true)
}
