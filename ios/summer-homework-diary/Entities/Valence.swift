//
//  Valence.swift
//  summer-homework-diary
//
//  Created by 유세헌 on 8/9/26.
//

enum Valence: Int, Codable {
    case veryUnpleasant = -3
    case unpleasant = -2
    case slightlyUnpleasant = -1
    case neutral = 0
    case slightlyPleasant = 1
    case pleasant = 2
    case veryPleasant = 3

    var displayName: String {
        switch self {
        case .veryUnpleasant: "아주 불쾌함"
        case .unpleasant: "불쾌함"
        case .slightlyUnpleasant: "약간 불쾌함"
        case .neutral: "보통"
        case .slightlyPleasant: "약간 기분 좋음"
        case .pleasant: "기분 좋음"
        case .veryPleasant: "아주 기분 좋음"
        }
    }

    var emotionValence: EmotionValence {
        rawValue == 0 ? .neutral : rawValue < 0 ? .unpleasant : .pleasant
    }
}
