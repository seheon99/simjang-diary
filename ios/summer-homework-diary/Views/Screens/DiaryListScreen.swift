//
//  DiaryListView.swift
//  summer-homework-diary
//

import SwiftUI
import SwiftData

enum DiaryRoute: Hashable {
    case write(Date)
    case detail(DiaryEntry)
}

struct DiaryListScreen: View {
    @Query(sort: \DiaryEntry.date, order: .reverse) private var entries: [DiaryEntry]
    @State private var path = NavigationPath()
    @State private var selectedDate = Calendar.current.startOfDay(for: .now)

    private var entriesByDay: [Date: [DiaryEntry]] {
        Dictionary(grouping: entries) { Calendar.current.startOfDay(for: $0.date) }
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                DiaryCalendarView(entriesByDay: entriesByDay, selectedDate: $selectedDate)

                let dayEntries = entriesByDay[selectedDate] ?? []
                if dayEntries.isEmpty {
                    ContentUnavailableView(
                        "이 날짜엔 쓴 일기가 없어요",
                        systemImage: "book.closed"
                    )
                } else {
                    List(dayEntries) { entry in
                        NavigationLink(value: DiaryRoute.detail(entry)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.date, style: .time)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(entry.text)
                                    .font(.body)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: DiaryRoute.self) { route in
                switch route {
                case .write(let date):
                    DiaryWriteScreen(path: $path, date: date)
                case .detail(let entry):
                    DiaryDetailScreen(entry: entry)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    path.append(DiaryRoute.write(selectedDate))
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.glassProminent)
                .clipShape(Circle())
                .padding(24)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: DiaryEntry.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    let samples = [
        DiaryEntry(date: today, text: "오늘은 수학 숙제를 끝냈다.", feedback: "잘했어요!"),
        DiaryEntry(date: calendar.date(byAdding: .day, value: -1, to: today)!, text: "친구랑 수영장에 갔다.", feedback: nil),
        DiaryEntry(date: calendar.date(byAdding: .day, value: -1, to: today)!, text: "친구랑 수영장에 갔다.", feedback: nil),
        DiaryEntry(date: calendar.date(byAdding: .day, value: -1, to: today)!, text: "친구랑 수영장에 갔다.", feedback: nil),
        DiaryEntry(date: calendar.date(byAdding: .day, value: -3, to: today)!, text: "책을 읽고 독서록을 썼다.", feedback: "다음엔 더 자세히 써보자."),
        DiaryEntry(date: calendar.date(byAdding: .day, value: -3, to: today)!, text: "책을 읽고 독서록을 썼다.", feedback: "다음엔 더 자세히 써보자."),
    ]
    samples.forEach { container.mainContext.insert($0) }

    return DiaryListScreen()
        .modelContainer(container)
}
