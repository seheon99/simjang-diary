//
//  WriteView.swift
//  summer-homework-diary
//

import SwiftUI
import SwiftData

struct WriteView: View {
    @Binding var path: NavigationPath

    @Environment(\.modelContext) private var modelContext

    @State private var userMessage = ""
    @State private var message = ""
    @State private var isGenerating = false
    @State private var hasDisappeared = false
    @FocusState private var isTextFieldFocused: Bool

    private let modelName = "kanana-1.5-2.1b-diary-100-4bit"

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
            .textFieldStyle(.plain)
            .lineLimit(5...15)
            .focused($isTextFieldFocused)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .glassEffect(
                .regular,
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )

            Spacer()

            Button {
                Task { await submit() }
            } label: {
                if isGenerating {
                    ProgressView().controlSize(.small)
                } else {
                    Label("제출", systemImage: "paperplane")
                }
            }
            .buttonStyle(.glassProminent)
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
            let engine = try await LLMEngine(modelName: modelName)
            let feedback = try await engine.generate(
                diary: diary,
                gender: "남",
                age: 28,
                includeSystemPrompt: false
            )

            let entry = DiaryEntry(date: .now, text: diary, feedback: feedback)
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
}

#Preview {
    NavigationStack {
        WriteView(path: .constant(NavigationPath()))
    }
}
