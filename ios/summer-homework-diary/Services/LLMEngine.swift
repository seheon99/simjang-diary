//
//  LLMEngine.swift
//  summer-homework-diary
//
//  Created by 유세헌 on 7/18/26.
//

import Foundation
import MLXHuggingFace
import MLXLMCommon
import MLXLLM
import MLX
import Tokenizers

import OSLog

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
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "simjang",
        category: "Performance"
    )

    init(modelName: String) async throws {
        Memory.cacheLimit = 2 * 1024 * 1024 // 2 MiB
        
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
        
        logger.debug("Loading Start")
        logger.debug("\(Memory.snapshot().description, privacy: .public)")

        let loadStart = ContinuousClock.now
        model = try await LLMModelFactory.shared.loadContainer(
            from: modelURL,
            using: #huggingFaceTokenizerLoader()
        )
        let loadEnd = ContinuousClock.now
        let loadTime = loadEnd - loadStart

        logger.debug("\(Memory.snapshot().description, privacy: .public)")
        logger.debug("Loading End: \(loadTime.description, privacy: .public)")
    }

    func generate(
        diary: String,
        gender: String,
        age: Int,
        includeSystemPrompt: Bool = false
    ) async throws -> String {
        logger.debug("Generation Start")
        logger.debug("\(Memory.snapshot().description, privacy: .public)")
        
        let session = ChatSession(
            model,
            instructions: includeSystemPrompt ? systemPrompt : nil,
            generateParameters: .init(maxTokens: 1024, temperature: 0)
        )
        let payload = UserPayload(gender: gender, age: age, diary: diary)
        let message = String(
            decoding: try JSONEncoder().encode(payload),
            as: UTF8.self
        )

        var text = ""
        var info: GenerateCompletionInfo?
        for try await generation in session.streamDetails(to: message) {
            if let chunk = generation.chunk { text += chunk }
            if let completion = generation.info { info = completion }
        }
        
        logger.debug("\(info?.summary() ?? "no completion info", privacy: .public)")
        logger.debug("\(Memory.snapshot().description, privacy: .public)")
        logger.debug("Generation End")

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
