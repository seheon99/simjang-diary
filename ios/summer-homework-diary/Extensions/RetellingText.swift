//
//  RetellingText.swift
//  summer-homework-diary
//

import Foundation

enum RetellingText {
    static func sanitize(_ raw: String) -> String {
        raw
            .replacing(#/<\|[^|>]*\|>/#, with: "")  // for <|eot_id|>
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
