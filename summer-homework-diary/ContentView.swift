//
//  ContentView.swift
//  summer-homework-diary
//
//  Created by 유세헌 on 7/18/26.
//

import SwiftUI

enum LoadState {
    case notLoaded
    case loading
    case loaded

    var title: String {
        switch self {
        case .notLoaded:
            "모델 로드되지 않음"
        case .loading:
            "모델 로딩 중"
        case .loaded:
            "모델 로드됨"
        }
    }

    var color: Color {
        switch self {
        case .notLoaded:
            .black
        case .loading:
            .gray
        case .loaded:
            .blue
        }
    }
}

struct ContentView: View {
    private let modelName = "kanana-1.5-2.1b-lut4-ctx256"

    @State private var engine: LLMEngine?
    @State private var loadState: LoadState = .notLoaded
    @State private var message = ""
    @State private var userMessage = ""
    @State private var botMessage = ""
    @State private var includeSystemPrompt = false
    @State private var isGenerating = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Kanana\nHomeroom Teacher").font(.title)

            Button {
                Task {
                    await loadModel(modelName)
                }
            } label: {
                Label {
                    Text("\(loadState.title) (\(modelName))")
                } icon: {
                    switch loadState {
                    case .notLoaded:
                        Image(systemName: "square.and.arrow.down")
                    case .loading:
                        ProgressView().controlSize(.small)
                    case .loaded:
                        Image(
                            systemName:
                                "square.and.arrow.down.badge.checkmark"
                        )
                    }
                }
            }
            .disabled(loadState != .notLoaded)
            .foregroundStyle(loadState.color)

            if !message.isEmpty {
                Text(message)
                    .font(.headline)
                    .foregroundStyle(Color.red)
                    .monospaced(true)
            }

            Spacer().frame(maxHeight: .infinity)

            Text(botMessage).font(.body)

            Spacer().frame(maxHeight: .infinity)

            Button(action: {
                includeSystemPrompt.toggle()
            }) {
                Label {
                    Text("시스템 프롬프트")
                } icon: {
                    Image(
                        systemName: includeSystemPrompt
                            ? "checkmark.square.fill" : "square"
                    )
                }
            }
            .buttonStyle(.glassProminent)
            .tint(includeSystemPrompt ? .accentColor : .gray)

            HStack(alignment: .center, spacing: 14) {
                TextField("메시지를 입력하세요", text: $userMessage, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .focused($isTextFieldFocused)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)

                Button {
                    Task { try await sendDiary(includeSystemPrompt) }
                } label: {
                    if isGenerating {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "paperplane")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.gray)
                    }
                }
                .buttonStyle(.glass)
                .layoutPriority(2)
                .disabled(
                    loadState != .loaded
                        || isGenerating
                        || userMessage.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                )
            }
            .padding(16)
            .glassEffect(
                .regular,
                in: RoundedRectangle(cornerRadius: 32, style: .continuous)
            )
        }
        .padding()
    }

    @MainActor
    private func loadModel(_ modelName: String) async {
        do {
            loadState = .loading
            engine = try await LLMEngine(modelName: modelName)
            loadState = .loaded
        } catch {
            loadState = .notLoaded
            message = error.localizedDescription
        }
    }

    @MainActor
    private func sendDiary(_ includeSystemPrompt: Bool) async throws {
        guard let engine else {
            throw LLMEngineError.modelNotFound("engine")
        }

        let diary = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)

        isGenerating = true
        message = ""
        defer { isGenerating = false }

        do {
            botMessage = try await engine.generate(
                diary: diary,
                gender: "남",
                age: 28,
                includeSystemPrompt: includeSystemPrompt
            )
            userMessage = ""
            isTextFieldFocused = false
        } catch {
            message = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
