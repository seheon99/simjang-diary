//
//  Weather.swift
//  summer-homework-diary
//
//  Created by 유세헌 on 8/9/26.
//

enum Weather: String, Codable {
    case sunny
    case cloudy
    case overcast
    case rainy
    case thunderstorm
    case snowy
    
    var displayName: String {
        switch self {
        case .sunny: "맑음"
        case .cloudy: "구름"
        case .overcast: "흐림"
        case .rainy: "비"
        case .thunderstorm: "천둥"
        case .snowy: "눈"
        }
    }
}
