//
//  DiaryListView.swift
//  summer-homework-diary
//

import SwiftUI
import SwiftData

enum DiaryRoute: Hashable {
    case write
    case detail(DiaryEntry)
}

struct DiaryListView: View {
    @Query(sort: \DiaryEntry.date, order: .reverse) private var entries: [DiaryEntry]
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "아직 작성한 일기가 없어요",
                        systemImage: "book.closed"
                    )
                } else {
                    List(entries) { entry in
                        NavigationLink(value: DiaryRoute.detail(entry)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.date, style: .date)
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
            .navigationTitle("여름방학 일기")
            .navigationDestination(for: DiaryRoute.self) { route in
                switch route {
                case .write:
                    WriteView(path: $path)
                case .detail(let entry):
                    EntryDetailView(entry: entry)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    path.append(DiaryRoute.write)
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
    DiaryListView()
        .modelContainer(for: DiaryEntry.self, inMemory: true)
}
