//
//  DiaryCalendarView.swift
//  summer-homework-diary
//
//  Created by 유세헌 on 8/4/26.
//

import SwiftUI

struct DiaryCalendarView: UIViewRepresentable {
    let entriesByDay: [Date: [DiaryEntry]]
    @Binding var selectedDate: Date

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        let gregorianCalendar = Calendar(identifier: .gregorian)

        calendarView.calendar = gregorianCalendar
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.fontDesign = .serif
        calendarView.availableDateRange = DateInterval(
            start: .distantPast,
            end: Calendar.current.startOfDay(for: .now).addingTimeInterval(86_400 - 1)
        )
        calendarView.delegate = context.coordinator
        calendarView.selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)

        return calendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.entriesByDay = entriesByDay

        let decoratedDates = entriesByDay.keys.map {
            Calendar.current.dateComponents([.year, .month, .day], from: $0)
        }
        uiView.reloadDecorations(forDateComponents: decoratedDates, animated: false)

        let selectedComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        if let singleDateSelection = uiView.selectionBehavior as? UICalendarSelectionSingleDate,
           singleDateSelection.selectedDate != selectedComponents {
            singleDateSelection.setSelected(selectedComponents, animated: true)
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UICalendarView, context: Context) -> CGSize? {
        CGSize(width: proposal.width ?? uiView.intrinsicContentSize.width, height: uiView.intrinsicContentSize.height)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(entriesByDay: entriesByDay, selectedDate: $selectedDate)
    }

    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var entriesByDay: [Date: [DiaryEntry]]
        @Binding var selectedDate: Date

        init(entriesByDay: [Date: [DiaryEntry]], selectedDate: Binding<Date>) {
            self.entriesByDay = entriesByDay
            self._selectedDate = selectedDate
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = Calendar.current.date(from: dateComponents) else { return nil }
            let count = min(entriesByDay[Calendar.current.startOfDay(for: date)]?.count ?? 0, 3)
            guard count > 0 else { return nil }

            return .customView {
                let width = CGFloat(count * 6)
                let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 6))
                view.backgroundColor = .tintColor
                view.layer.cornerRadius = 3
                return view
            }
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents, let date = Calendar.current.date(from: dateComponents) else { return }
            selectedDate = Calendar.current.startOfDay(for: date)
        }
    }
}

#Preview {
    let calendar = Calendar.current
    let entriesByDay: [Date: [DiaryEntry]] = [-3, -3, -1, -1, -1, 0].reduce(into: [:]) { result, offset in
        let day = calendar.startOfDay(for: calendar.date(byAdding: .day, value: offset, to: .now)!)
        let diary = DiaryEntry(date: day, text: "미리보기 일기 \(offset)")
        if result[day] != nil {
            result[day]?.append(diary)
        } else {
            result[day] = [diary]
        }
    }
    DiaryCalendarView(entriesByDay: entriesByDay, selectedDate: .constant(.now))
}
