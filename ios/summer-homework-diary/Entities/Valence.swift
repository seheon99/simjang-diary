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
        case .veryUnpleasant: "매우 불쾌해요"
        case .unpleasant: "불쾌해요"
        case .slightlyUnpleasant: "조금 불쾌해요"
        case .neutral: "보통이에요"
        case .slightlyPleasant: "조금 좋아요"
        case .pleasant: "좋아요"
        case .veryPleasant: "매우 좋아요"
        }
    }

    var emotionValence: EmotionValence {
        rawValue == 0 ? .neutral : rawValue < 0 ? .unpleasant : .pleasant
    }
}
