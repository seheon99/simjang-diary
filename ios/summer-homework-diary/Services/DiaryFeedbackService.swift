//
//  DiaryFeedbackService.swift
//  summer-homework-diary
//

struct DiaryFeedbackService {
    private let modelName = "kanana-1.5-2.1b-instruct-mlx-int4"

    func generate(
        for entry: DiaryEntry,
        includeSystemPrompt: Bool
    ) async throws -> String {
        let engine = try await LLMEngine(modelName: modelName)
        return try await engine.comment(
            diary: entry,
            retelling: nil,
            includeSystemPrompt: includeSystemPrompt
        )
    }
}
