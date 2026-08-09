//
//  DiaryEntry.swift
//  summer-homework-diary
//

import Foundation
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

    init(
        date: Date = .now,
        text: String,
        weather: Weather? = nil,
        valence: Valence = .neutral,
        emotions: [Emotion] = [],
        feedback: String? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.text = text
        self.weather = weather
        self.valence = valence
        self.emotions = emotions
        self.feedback = feedback
    }
}
