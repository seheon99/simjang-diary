//
//  App.swift
//  summer-homework-diary
//
//  Created by 유세헌 on 7/18/26.
//

import SwiftUI
import SwiftData

@main
struct DiaryApp: App {
    var body: some Scene {
        WindowGroup {
            DiaryListScreen()
        }
        .modelContainer(for: DiaryEntry.self)
    }
}
