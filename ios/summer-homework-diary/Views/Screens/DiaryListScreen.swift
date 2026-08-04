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
            .navigationTitle("일기장")
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
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                }
                .buttonStyle(.glassProminent)
                .clipShape(Circle())
                .padding(24)
            }
        }
    }
}

#Preview {
    DiaryListScreen()
        .modelContainer(for: DiaryEntry.self, inMemory: true)
}
