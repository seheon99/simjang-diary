//
//  DiaryFeedbackService.swift
//  summer-homework-diary
//

struct DiaryFeedbackService {
    struct Output {
        let retelling: String?
        let comment: String
    }

    private let modelName = "kanana-1.5-2.1b-instruct-mlx-int4"

    func generate(
        for entry: DiaryEntry,
        includeSystemPrompt: Bool
    ) async throws -> Output {
        let engine = try await LLMEngine(modelName: modelName)

        // The retelling is an enhancement to the comment, never a
        // precondition for it. A failed or empty retelling degrades to
        // the previous behavior rather than failing the whole request.
        let retelling: String?
        if let raw = try? await engine.retell(diary: entry) {
            let sanitized = RetellingText.sanitize(raw)
            retelling = sanitized.isEmpty ? nil : sanitized
        } else {
            retelling = nil
        }

        let comment = try await engine.comment(
            diary: entry,
            retelling: retelling,
            includeSystemPrompt: includeSystemPrompt
        )

        return Output(retelling: retelling, comment: comment)
    }
}
