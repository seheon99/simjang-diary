//
//  RetellingText.swift
//  summer-homework-diary
//

import Foundation

enum RetellingText {
    /// Removes chat-template special tokens (e.g. `<|eot_id|>`) that some
    /// model builds emit into generated text, then trims surrounding whitespace.
    static func sanitize(_ raw: String) -> String {
        raw
            .replacing(#/<\|[^|>]*\|>/#, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
