//
//  DiaryEntry.swift
//  summer-homework-diary
//

import Foundation
import NaturalLanguage
import SwiftData

@Model
final class DiaryEntry {
    var id: UUID
    var date: Date
    var text: String
    var weather: Weather?
    var valence: Valence = Valence.neutral
    var emotions: [Emotion] = []
    var feedback: String?
    var retelling: String?

    init(
        date: Date = .now,
        text: String,
        weather: Weather? = nil,
        valence: Valence = .neutral,
        emotions: [Emotion] = [],
        feedback: String? = nil,
        retelling: String? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.text = text
        self.weather = weather
        self.valence = valence
        self.emotions = emotions
        self.feedback = feedback
        self.retelling = retelling
    }

    var firstSentence: String {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        var sentence = text
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            sentence = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            return false
        }
        return sentence
    }
}
