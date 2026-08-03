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
    var feedback: String?

    init(date: Date = .now, text: String, feedback: String? = nil) {
        self.id = UUID()
        self.date = date
        self.text = text
        self.feedback = feedback
    }
}
