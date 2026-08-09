//
//  Emotion.swift
//  summer-homework-diary
//
//  Created by 유세헌 on 8/9/26.
//

enum EmotionValence: Codable, CaseIterable {
    case pleasant
    case neutral
    case unpleasant
    
    var emotions: [Emotion] {
        Emotion.allCases.filter { $0.valence == self }
    }
}

enum Emotion: String, Codable, CaseIterable, Identifiable {
    case dissatisfaction
    case embarrassment
    case irritation
    case sadness
    case despair
    case shame
    case boredom
    case disappointment
    case disgust
    case pity
    case shock
    case burden
    case fear
    case hatred
    case guilt
    case worry
    case doubt
    case anger
    case selfHatred
    case sorrow
    case fedUp
    case absurdity
    case compassion
    case pathetic
    case exhaustion

    case admiration
    case happiness
    case joy
    case gratitude
    case pleasure
    case caring
    case anticipation
    case comfort
    case favor
    case interest
    case trust
    case respect
    case pleased
    case pride

    case surprise
    case realization
    case determination

    var id: Self { self }

    var displayName: String {
        switch self {
        case .dissatisfaction:
            "불만"
        case .embarrassment:
            "당황"
        case .irritation:
            "짜증"
        case .sadness:
            "슬픔"
        case .despair:
            "절망"
        case .shame:
            "부끄러움"
        case .boredom:
            "재미없음"
        case .disappointment:
            "실망"
        case .disgust:
            "역겨움"
        case .pity:
            "안타까움"
        case .shock:
            "경악"
        case .burden:
            "부담"
        case .fear:
            "공포"
        case .hatred:
            "증오"
        case .guilt:
            "죄책감"
        case .worry:
            "걱정"
        case .doubt:
            "의심"
        case .anger:
            "화남"
        case .selfHatred:
            "자기혐오"
        case .sorrow:
            "서러움"
        case .fedUp:
            "지긋지긋"
        case .absurdity:
            "어이없음"
        case .compassion:
            "불쌍함"
        case .pathetic:
            "한심함"
        case .exhaustion:
            "지침"

        case .admiration:
            "감동"
        case .happiness:
            "행복"
        case .joy:
            "기쁨"
        case .gratitude:
            "고마움"
        case .pleasure:
            "즐거움"
        case .caring:
            "아낌"
        case .anticipation:
            "기대감"
        case .comfort:
            "편안함"
        case .favor:
            "호의"
        case .interest:
            "관심"
        case .trust:
            "신뢰"
        case .respect:
            "존경"
        case .pleased:
            "흐뭇함"
        case .pride:
            "뿌듯함"

        case .surprise:
            "놀람"
        case .realization:
            "깨달음"
        case .determination:
            "비장함"
        }
    }

    var valence: EmotionValence {
        switch self {
        case .dissatisfaction,
             .embarrassment,
             .irritation,
             .sadness,
             .despair,
             .shame,
             .boredom,
             .disappointment,
             .disgust,
             .pity,
             .shock,
             .burden,
             .fear,
             .hatred,
             .guilt,
             .worry,
             .doubt,
             .anger,
             .selfHatred,
             .sorrow,
             .fedUp,
             .absurdity,
             .compassion,
             .pathetic,
             .exhaustion:
            .unpleasant

        case .admiration,
             .happiness,
             .joy,
             .gratitude,
             .pleasure,
             .caring,
             .anticipation,
             .comfort,
             .favor,
             .interest,
             .trust,
             .respect,
             .pleased,
             .pride:
            .pleasant

        case .surprise,
             .realization,
             .determination:
            .neutral
        }
    }
}
