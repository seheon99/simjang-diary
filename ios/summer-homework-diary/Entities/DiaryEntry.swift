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
    var weather: Weather
    var emotion: Emotion
    var valence: Valence
    var feedback: String?

    init(
        date: Date = .now,
        text: String,
        weather: Weather,
        emotion: Emotion,
        valence: Valence,
        feedback: String? = nil) {
        self.id = UUID()
        self.date = date
        self.text = text
        self.feedback = feedback
    }
}
