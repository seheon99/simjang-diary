//
//  WriteView.swift
//  summer-homework-diary
//

import SwiftUI
import SwiftData

import MLX

struct DiaryWriteScreen: View {
    @Binding var path: NavigationPath
    let date: Date

    @Environment(\.modelContext) private var modelContext

    @State private var userMessage = ""
    @State private var message = ""
    @State private var isGenerating = false
    @State private var hasDisappeared = false
    @State private var enableSystemPrompt = true
    @FocusState private var isTextFieldFocused: Bool

    private let modelName = "kanana-1.5-2.1b-instruct-mlx-int4"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("오늘의 일기").font(.title)

            if !message.isEmpty {
                Text(message)
                    .font(.headline)
                    .foregroundStyle(Color.red)
                    .monospaced(true)
            }

            TextField(
                "오늘 있었던 일을 적어보세요",
                text: $userMessage,
                axis: .vertical
            )
            .lineLimit(5...20)
            .focused($isTextFieldFocused)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textFieldStyle(.roundedBorder)

            Spacer()
            
            #if DEBUG
            Toggle("시스템 프롬프트", isOn: $enableSystemPrompt)
            #endif
            
            Button {
                Task { await submit() }
            } label: {
                if isGenerating {
                    ProgressView().controlSize(.large)
                } else {
                    Label("제출", systemImage: "paperplane").controlSize(.large).padding(.vertical, 6)
                }
            }
            .buttonStyle(.glassProminent).buttonSizing(.flexible)
            .disabled(
                isGenerating
                    || userMessage.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty
            )
        }
        .padding()
        .navigationTitle("일기 작성")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            hasDisappeared = true
        }
    }

    @MainActor
    private func submit() async {
        let diary = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !diary.isEmpty else { return }

        isGenerating = true
        message = ""
        defer { isGenerating = false }

        do {
            var engine: LLMEngine!
            var result: String

            engine = try await LLMEngine(modelName: modelName)
            result = try await engine.generate(
                diary: diary,
                gender: "남",
                age: 28,
                includeSystemPrompt: enableSystemPrompt
            )

            let entry = DiaryEntry(date: entryTimestamp(), text: diary, feedback: result)
            modelContext.insert(entry)

            userMessage = ""
            isTextFieldFocused = false

            if !hasDisappeared {
                path.removeLast()
                path.append(DiaryRoute.detail(entry))
            }
        } catch {
            message = error.localizedDescription
        }
    }

    private func entryTimestamp() -> Date {
        let calendar = Calendar.current
        let timeOfDay = calendar.dateComponents([.hour, .minute, .second], from: .now)
        return calendar.date(
            bySettingHour: timeOfDay.hour ?? 0,
            minute: timeOfDay.minute ?? 0,
            second: timeOfDay.second ?? 0,
            of: calendar.startOfDay(for: date)
        ) ?? date
    }
}

#Preview {
    NavigationStack {
        DiaryWriteScreen(path: .constant(NavigationPath()), date: .now)
    }
}
