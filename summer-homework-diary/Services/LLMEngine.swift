//
//  LLMEngine.swift
//  summer-homework-diary
//
//  Created by 유세헌 on 7/18/26.
//

import Foundation
import MLXHuggingFace
import MLXLLM
import MLXLMCommon
import Tokenizers

enum LLMEngineError: LocalizedError {
    case modelNotFound(String)
    case systemPromptNotFound

    var errorDescription: String? {
        switch self {
        case .modelNotFound(let modelName):
            "\(modelName)를 앱 번들에서 찾을 수 없습니다."
        case .systemPromptNotFound:
            "system-prompt.md를 앱 번들에서 찾을 수 없습니다."
        }
    }
}

actor LLMEngine {
    private struct UserPayload: Encodable {
        let gender: String
        let age: Int
        let diary: String
    }

    nonisolated let modelName: String

    private let model: ModelContainer
    private let systemPrompt: String

    init(modelName: String) async throws {
        self.modelName = modelName

        guard
            let modelURL = Bundle.main.url(
                forResource: modelName,
                withExtension: nil
            )
        else {
            throw LLMEngineError.modelNotFound(modelName)
        }
        guard
            let systemPromptURL = Bundle.main.url(
                forResource: "system-prompt",
                withExtension: "md"
            )
        else {
            throw LLMEngineError.systemPromptNotFound
        }

        systemPrompt = try String(
            contentsOf: systemPromptURL,
            encoding: .utf8
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)
        model = try await LLMModelFactory.shared.loadContainer(
            from: modelURL,
            using: #huggingFaceTokenizerLoader()
        )
    }

    func generate(
        diary: String,
        gender: String,
        age: Int,
        includeSystemPrompt: Bool = false
    ) async throws -> String {
        let session = ChatSession(
            model,
            instructions: includeSystemPrompt ? systemPrompt : nil,
            generateParameters: .init(maxTokens: 100, temperature: 0)
        )
        let payload = UserPayload(gender: gender, age: age, diary: diary)
        let message = String(
            decoding: try JSONEncoder().encode(payload),
            as: UTF8.self
        )

        return try await session.respond(to: message)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
