//
//  Font+Diary.swift
//  summer-homework-diary
//
//  Created by 유세헌 on 8/9/26.
//

import SwiftUI

extension Font {
    static let diaryTitle = Font.custom(
        "MaruBuri-Bold",
        size: 28,
        relativeTo: .title
    )
    
    static let diaryHeadline = Font.custom(
        "MaruBuri-SemiBold",
        size: 18,
        relativeTo: .headline
    )
    
    static let diaryBody = Font.custom(
        "MaruBuri-Regular",
        size: 24,
        relativeTo: .body
    )
    
    static let diaryComment = Font.custom(
        "MaruBuri-Regular",
        size: 24,
        relativeTo: .body
    )
    
    static let diaryCaption = Font.custom(
        "MaruBuri-Light",
        size: 13,
        relativeTo: .caption
    )
    
    static let diaryRegular = Font.custom(
        "MaruBuri-Regular",
        size: 17,
        relativeTo: .body
    )
}
