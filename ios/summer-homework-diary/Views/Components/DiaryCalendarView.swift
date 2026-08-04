//
//  DiaryCalendarView.swift
//  summer-homework-diary
//
//  Created by 유세헌 on 8/4/26.
//

import SwiftUI

struct DiaryCalendarView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let calendarView = UICalendarView()
        let gregorianCalendar = Calendar(identifier: .gregorian)
        
        calendarView.calendar = gregorianCalendar
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.fontDesign = .rounded
        
        return calendarView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
