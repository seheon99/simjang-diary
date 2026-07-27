//
//  LLMEngine.swift
//  summer-homework-diary
//
//  Created by 유세헌 on 7/18/26.
//

import CoreML
import Foundation
import Generation
import Tokenizers

enum LLMEngineError: LocalizedError {
    case modelNotFound(String)
    case tokenizerNotFound
    case systemPromptNotFound
    case invalidModelContract
    case inputTooLong(contextLength: Int)

    var errorDescription: String? {
        switch self {
        case .modelNotFound(let modelName):
            "\(modelName).mlmodelc를 앱 번들에서 찾을 수 없습니다."
        case .tokenizerNotFound:
            "tokenizer 폴더를 앱 번들에서 찾을 수 없습니다."
        case .systemPromptNotFound:
            "system-prompt.md를 앱 번들에서 찾을 수 없습니다."
        case .invalidModelContract:
            "모델이 stateful KV cache 입출력 형식과 맞지 않습니다."
        case .inputTooLong(let contextLength):
            "시스템 프롬프트와 일기가 \(contextLength)토큰 컨텍스트보다 깁니다."
        }
    }
}

@available(iOS 18.0, macOS 15.0, *)
nonisolated private final class ChunkedStatefulLanguageModel: Generation {
    let maxContextLength: Int

    private let coreMLModel: MLModel
    private let prefillChunkSize: Int

    private var state: MLState?
    private var didPrefill = false

    init(
        coreMLModel: MLModel,
        maxContextLength: Int = 256,
        prefillChunkSize: Int
    ) {
        precondition(prefillChunkSize > 0)
        precondition(prefillChunkSize <= maxContextLength)

        self.coreMLModel = coreMLModel
        self.maxContextLength = maxContextLength
        self.prefillChunkSize = prefillChunkSize
    }

    func resetState() async {
        state = coreMLModel.makeState()
        didPrefill = false
    }

    func predictNextTokenScores(
        _ tokens: MLTensor,
        config _: GenerationConfig
    ) async -> MLTensor {
        guard let state else {
            fatalError("resetState() must be called before generation.")
        }

        let tokenArray =
            await tokens
            .shapedArray(of: Int32.self)
            .scalars

        precondition(!tokenArray.isEmpty)
        precondition(tokenArray.count <= maxContextLength)

        if didPrefill {
            let lastTokenIndex = tokenArray.count - 1
            let inputIds = MLTensor(
                shape: [1, 1],
                scalars: [tokenArray[lastTokenIndex]],
                scalarType: Int32.self
            )
            let cachePosition = MLTensor(
                shape: [1],
                scalars: [Int32(lastTokenIndex)],
                scalarType: Int32.self
            )

            return await predict(
                inputIds: inputIds,
                causalMask: Self.causalMask(
                    position: lastTokenIndex,
                    contextLength: maxContextLength
                ),
                cachePosition: cachePosition,
                state: state,
                phase: "decode",
                range: lastTokenIndex..<tokenArray.count
            )
        }

        var lastScores: MLTensor?
        var start = 0

        while start < tokenArray.count {
            let end = min(start + prefillChunkSize, tokenArray.count)
            let chunk = Array(tokenArray[start..<end])
            let inputIds = MLTensor(
                shape: [1, chunk.count],
                scalars: chunk,
                scalarType: Int32.self
            )
            let cachePosition = MLTensor(
                shape: [chunk.count],
                scalars: (start..<end).map(Int32.init),
                scalarType: Int32.self
            )

            lastScores = await predict(
                inputIds: inputIds,
                causalMask: Self.causalMask(
                    position: start,
                    queryLength: chunk.count,
                    contextLength: maxContextLength
                ),
                cachePosition: cachePosition,
                state: state,
                phase: "prefill",
                range: start..<end
            )
            start = end
        }

        didPrefill = true

        guard let lastScores else {
            fatalError("Prefill produced no logits.")
        }
        return lastScores
    }

    private func predict(
        inputIds: MLTensor,
        causalMask: MLTensor,
        cachePosition: MLTensor,
        state: MLState,
        phase: String,
        range: Range<Int>
    ) async -> MLTensor {
        let label = "\(phase) tokens=\(range)"

        let inputIdsArray = MLMultiArray(
            await inputIds.shapedArray(of: Int32.self)
        )
        let causalMaskArray = MLMultiArray(
            await causalMask.shapedArray(of: Float16.self)
        )
        let cachePositionArray = MLMultiArray(
            await cachePosition.shapedArray(of: Int32.self)
        )
        let inputs = try! MLDictionaryFeatureProvider(
            dictionary: [
                "inputIds": MLFeatureValue(multiArray: inputIdsArray),
                "causalMask": MLFeatureValue(multiArray: causalMaskArray),
                "cachePosition": MLFeatureValue(
                    multiArray: cachePositionArray
                ),
            ]
        )
        let outputs = try! await coreMLModel.prediction(
            from: inputs,
            using: state
        )

        guard
            let logits = outputs.featureValue(for: "logits")?.multiArrayValue
        else {
            fatalError("Core ML output does not contain logits.")
        }
        let scores = MLShapedArray<Float16>(logits)
        precondition(scores.shape == [1, 1, 128_259])
        return MLTensor(
            shape: scores.shape,
            scalars: scores.scalars,
            scalarType: Float16.self
        )
    }

    private static func causalMask(
        position: Int,
        queryLength: Int = 1,
        contextLength: Int
    ) -> MLTensor {
        var values = [Float16](
            repeating: 0,
            count: queryLength * contextLength
        )
        let negativeInfinity = -Float16.infinity

        for query in 0..<queryLength {
            let firstFutureKey = position + query + 1
            guard firstFutureKey < contextLength else {
                continue
            }

            for key in firstFutureKey..<contextLength {
                values[query * contextLength + key] = negativeInfinity
            }
        }

        return MLTensor(
            shape: [1, 1, queryLength, contextLength],
            scalars: values,
            scalarType: Float16.self
        )
    }
}

@available(iOS 18.0, macOS 15.0, *)
actor LLMEngine {
    private struct UserPayload: Encodable {
        let gender: String
        let age: Int
        let diary: String
    }

    nonisolated let modelName: String

    private let model: ChunkedStatefulLanguageModel
    private let tokenizer: any Tokenizer
    private let systemPrompt: String

    init(
        modelName: String,
        prefillChunkSize: Int = 1
    ) async throws {
        self.modelName = modelName

        guard
            let modelURL = Bundle.main.url(
                forResource: modelName,
                withExtension: "mlmodelc"
            )
        else {
            throw LLMEngineError.modelNotFound(modelName)
        }
        guard
            let tokenizerURL = Bundle.main.url(
                forResource: "tokenizer",
                withExtension: nil
            )
        else {
            throw LLMEngineError.tokenizerNotFound
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
        tokenizer = try await AutoTokenizer.from(modelFolder: tokenizerURL)

        let configuration = MLModelConfiguration()
        configuration.computeUnits = .cpuAndNeuralEngine

        var optimizationHints = MLOptimizationHints()
        optimizationHints.reshapeFrequency = .frequent
        configuration.optimizationHints = optimizationHints

        let coreMLModel = try MLModel(
            contentsOf: modelURL,
            configuration: configuration
        )

        guard Self.hasExpectedContract(coreMLModel) else {
            throw LLMEngineError.invalidModelContract
        }

        model = ChunkedStatefulLanguageModel(
            coreMLModel: coreMLModel,
            maxContextLength: 256,
            prefillChunkSize: prefillChunkSize
        )
    }

    func generate(
        diary: String,
        gender: String,
        age: Int,
        includeSystemPrompt: Bool = false
    ) async throws -> String {
        let userMessage = try Self.userMessage(
            diary: diary,
            gender: gender,
            age: age
        )

        var messages: [Message] = []
        if includeSystemPrompt {
            messages.append(["role": "system", "content": systemPrompt])
        }
        messages.append(["role": "user", "content": userMessage])

        let promptTokens = try tokenizer.applyChatTemplate(messages: messages)
        let maxNewTokens = min(
            8,
            model.maxContextLength - promptTokens.count
        )
        guard maxNewTokens > 0 else {
            throw LLMEngineError.inputTooLong(
                contextLength: model.maxContextLength
            )
        }

        var config = GenerationConfig(maxNewTokens: maxNewTokens)
        config.maxLength = promptTokens.count + maxNewTokens
        config.doSample = false
        config.padTokenId = 128_001
        config.bosTokenId = tokenizer.bosTokenId
        config.eosTokenId = tokenizer.eosTokenId

        await model.resetState()

        let predictor: NextTokenModel = { [model] tokens, config in
            await model.predictNextTokenScores(tokens, config: config)
        }
        let outputTokens = await model.generate(
            config: config,
            tokens: promptTokens,
            model: predictor
        )

        return tokenizer.decode(
            tokens: Array(outputTokens.dropFirst(promptTokens.count))
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func userMessage(
        diary: String,
        gender: String,
        age: Int
    ) throws -> String {
        let payload = UserPayload(gender: gender, age: age, diary: diary)
        return String(
            decoding: try JSONEncoder().encode(payload),
            as: UTF8.self
        )
    }

    private static func hasExpectedContract(_ model: MLModel) -> Bool {
        let description = model.modelDescription
        let inputs = description.inputDescriptionsByName
        let outputs = description.outputDescriptionsByName
        let states = description.stateDescriptionsByName

        return inputs["inputIds"] != nil
            && inputs["causalMask"] != nil
            && inputs["cachePosition"] != nil
            && outputs["logits"] != nil
            && states["keyCache"] != nil
            && states["valueCache"] != nil
    }
}
