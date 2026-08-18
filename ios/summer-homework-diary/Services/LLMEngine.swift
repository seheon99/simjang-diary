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
    case promptNotFound(String)

    var errorDescription: String? {
        switch self {
        case .modelNotFound(let modelName):
            "\(modelName)를 앱 번들에서 찾을 수 없습니다."
        case .promptNotFound(let promptName):
            "\(promptName).md를 앱 번들에서 찾을 수 없습니다."
        }
    }
}

actor LLMEngine {
    private struct UserPayload: Encodable {
        let date: Date
        let text: String
        let weather: Weather?
        let valence: Valence
        let emotions: [Emotion]
        let retelling: String?
    }

    private struct RetellPayload: Encodable {
        let date: String
        let text: String
    }

    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        // Must be the local zone. ISO8601DateFormatter defaults to GMT, which
        // would label a diary written at 08:00 KST as the previous day.
        formatter.timeZone = .current
        return formatter
    }()

    nonisolated let modelName: String

    private let model: ModelContainer
    private let systemPrompt: String
    private let retellPrompt: String

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "simjang",
        category: "Performance"
    )

    init(modelName: String) async throws {
        Memory.memoryLimit = 2 * 1024 * 1024 * 1024 // 2 GiB
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
        systemPrompt = try Self.loadPrompt(named: "system-prompt")
        retellPrompt = try Self.loadPrompt(named: "retell-prompt")

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

    private static func loadPrompt(named name: String) throws -> String {
        guard
            let url = Bundle.main.url(forResource: name, withExtension: "md")
        else {
            throw LLMEngineError.promptNotFound(name)
        }
        return try String(contentsOf: url, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func retell(diary: DiaryEntry) async throws -> String {
        logger.debug("Retell Start")

        let session = ChatSession(
            model,
            instructions: retellPrompt,
            generateParameters: .init(maxTokens: 256, temperature: 0)
        )
        let payload = RetellPayload(
            date: Self.dateFormatter.string(from: diary.date),
            text: diary.text
        )
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
        logger.debug("Retell End")

        return text
    }

    func comment(
        diary: DiaryEntry,
        retelling: String?,
        includeSystemPrompt: Bool = false
    ) async throws -> String {
        logger.debug("Comment Start")
        logger.debug("\(Memory.snapshot().description, privacy: .public)")

        let session = ChatSession(
            model,
            instructions: includeSystemPrompt ? systemPrompt : nil,
            generateParameters: .init(maxTokens: 1024, temperature: 0)
        )
        let payload = UserPayload(
            date: diary.date,
            text: diary.text,
            weather: diary.weather,
            valence: diary.valence,
            emotions: diary.emotions,
            retelling: retelling
        )
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
        logger.debug("Comment End")

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
