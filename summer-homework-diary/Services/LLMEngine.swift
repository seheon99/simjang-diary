//
//  LLMEngine.swift
//  summer-homework-diary
//
//  Created by 유세헌 on 7/18/26.
//

import Foundation
import CoreML

enum LLMEngineError: LocalizedError {
    case modelNotFound

    var errorDescription: String? {
        switch self {
        case .modelNotFound:
            return "FineTunedLLM 모델을 앱 번들에서 찾을 수 없습니다."
        }
    }
}

final class LLMEngine {
    public let modelName: String
    
    private let model: MLModel
    private let state: MLState

    init() async throws {
        modelName = "kanana-1.5-2.1b-instruct-diary-100-q4"

        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all

        guard let modelURL = Bundle.main.url(
            forResource: modelName,
            withExtension: "mlmodelc",
        ) else {
            throw LLMEngineError.modelNotFound
        }

        let asset = try MLModelAsset(url: modelURL)
        let loadedModel = try await MLModel.load(
            asset: asset,
            configuration: configuration
        )

        self.model = loadedModel
        self.state = loadedModel.makeState()
    }

    func predict(
        input: MLFeatureProvider
    ) async throws -> MLFeatureProvider {
        try await model.prediction(
            from: input,
            using: state
        )
    }
}
