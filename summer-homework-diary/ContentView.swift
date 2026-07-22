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
    @State private var engine: LLMEngine?
    @State private var loadState: LoadState = .notLoaded
    @State private var message = ""
    @State private var userMessage = ""
    @State private var botMessage = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Kanana\nHomeroom Teacher").font(.title)

            Button {
                Task {
                    await loadModel()
                }
            } label: {
                Label {
                    Text(loadState.title)
                } icon: {
                    switch loadState {
                    case .notLoaded:
                        Image(systemName: "square.and.arrow.down")
                    case .loading:
                        ProgressView().controlSize(.small)
                    case .loaded:
                        Image(
                            systemName: "square.and.arrow.down.badge.checkmark"
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

            HStack(alignment: .center, spacing: 14) {
                TextField("메시지를 입력하세요", text: $userMessage, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .focused($isTextFieldFocused)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
                Button {
                    print("Hello")
                } label: {
                    Image(systemName: "paperplane")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.gray)
                }
                .buttonStyle(.glass)
                .layoutPriority(2)
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
    private func loadModel() async {
        do {
            loadState = .loading
            engine = try await LLMEngine()
            loadState = .loaded
        } catch {
            loadState = .notLoaded
            message = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
