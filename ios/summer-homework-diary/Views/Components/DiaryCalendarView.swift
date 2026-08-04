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
        calendarView.fontDesign = .rounded
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
                let stack = UIStackView()
                stack.axis = .horizontal
                stack.spacing = 2
                for _ in 0..<count {
                    let dot = UIView()
                    dot.backgroundColor = .systemOrange
                    dot.layer.cornerRadius = 2
                    dot.translatesAutoresizingMaskIntoConstraints = false
                    dot.widthAnchor.constraint(equalToConstant: 4).isActive = true
                    dot.heightAnchor.constraint(equalToConstant: 4).isActive = true
                    stack.addArrangedSubview(dot)
                }
                return stack
            }
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents, let date = Calendar.current.date(from: dateComponents) else { return }
            selectedDate = Calendar.current.startOfDay(for: date)
        }
    }
}

#Preview {
    DiaryCalendarView(entriesByDay: [:], selectedDate: .constant(.now))
}
