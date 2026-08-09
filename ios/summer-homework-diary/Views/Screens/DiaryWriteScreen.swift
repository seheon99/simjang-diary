//
//  WriteView.swift
//  summer-homework-diary
//

import SwiftUI
import SwiftData

import MLX

import OSLog

struct DiaryWriteScreen: View {
    private enum Step: Int {
        case weather
        case valence
        case emotions
        case diary
    }

    @Binding var path: NavigationPath
    let date: Date

    @Environment(\.modelContext) private var modelContext

    @State private var step = Step.weather
    @State private var selectedWeather: Weather?
    @State private var valenceValue = 0.0
    @State private var selectedEmotions: Set<Emotion> = []
    @State private var showsAllEmotions = false
    @State private var userMessage = ""
    @State private var isGenerating = false
    @State private var showsSubmissionError = false
    @State private var hasDisappeared = false
    @State private var enableSystemPrompt = true
    @FocusState private var isTextFieldFocused: Bool

    private var valence: Valence {
        Valence(rawValue: Int(valenceValue.rounded())) ?? .neutral
    }

    private let modelName = "kanana-1.5-2.1b-instruct-mlx-int4"

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "simjang",
        category: "Performance"
    )

    var body: some View {
        content
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(step != .weather)
            .toolbar {
                if step != .weather {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            if let previous = Step(rawValue: step.rawValue - 1) {
                                step = previous
                            }
                        } label: {
                            Label("이전", systemImage: "chevron.left")
                        }
                    }
                }
            }
            .alert("일기를 저장하지 못했어요", isPresented: $showsSubmissionError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("다시 시도해 주세요.")
            }
            .onDisappear {
                hasDisappeared = true
            }
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .weather: weatherStep
        case .valence: valenceStep
        case .emotions: emotionStep
        case .diary: diaryStep
        }
    }

    private var weatherStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("오늘 날씨는 어땠나요?")
                .font(.diaryTitle)

            HStack(spacing: 4) {
                ForEach(Weather.allCases) { weather in
                    Button {
                        selectedWeather = selectedWeather == weather ? nil : weather
                    } label: {
                        Text(weather.displayName)
                            .font(.diaryCaption)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(selectedWeather == weather ? .taupe700 : .taupe300)
                    .accessibilityAddTraits(
                        selectedWeather == weather ? .isSelected : []
                    )
                }
            }

            Spacer()

            Button("다음") {
                step = .valence
            }
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
        }
    }

    private var valenceStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("오늘 기분은 어땠나요?")
                .font(.diaryTitle)

            Text(valence.displayName)
                .font(.diaryHeadline)

            Slider(value: $valenceValue, in: -3...3) {
                Text("오늘의 기분")
            } minimumValueLabel: {
                Text("-3")
            } maximumValueLabel: {
                Text("3")
            }
            .accessibilityValue(valence.displayName)

            Spacer()

            Button("다음") {
                step = .emotions
            }
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
        }
    }

    private var emotionStep: some View {
        let matchingEmotions = valence.emotionValence.emotions

        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("어떤 감정을 느꼈나요?")
                    .font(.diaryTitle)

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 88), spacing: 8)],
                    spacing: 8
                ) {
                    ForEach(matchingEmotions) { emotion in
                        emotionButton(emotion)
                    }

                    if showsAllEmotions {
                        ForEach(
                            Emotion.allCases.filter {
                                $0.valence != valence.emotionValence
                            }
                        ) { emotion in
                            emotionButton(emotion)
                        }
                    }
                }

                if !showsAllEmotions {
                    Button("더 보기") {
                        showsAllEmotions = true
                    }
                }

                Button("다음") {
                    step = .diary
                }
                .buttonStyle(.glassProminent)
                .buttonSizing(.flexible)
                .disabled(selectedEmotions.isEmpty)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func emotionButton(_ emotion: Emotion) -> some View {
        let isSelected = selectedEmotions.contains(emotion)

        return Button {
            selectedEmotions.formSymmetricDifference([emotion])
        } label: {
            Text(emotion.displayName)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.borderedProminent)
        .tint(isSelected ? .taupe700 : .taupe300)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var diaryStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            TextField(
                "오늘 있었던 일을 적어보세요",
                text: $userMessage,
                axis: .vertical
            )
            .lineLimit(5...20)
            .focused($isTextFieldFocused)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textFieldStyle(.roundedBorder)

            Spacer()

            #if DEBUG
            Toggle("시스템 프롬프트", isOn: $enableSystemPrompt)
            #endif

            Button {
                Task { await submit() }
            } label: {
                if isGenerating {
                    ProgressView().controlSize(.large)
                } else {
                    Label("제출", systemImage: "paperplane")
                        .controlSize(.large)
                        .padding(.vertical, 6)
                }
            }
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
            .disabled(
                isGenerating
                    || userMessage.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty
            )
        }
    }

    @MainActor
    private func submit() async {
        let diary = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !diary.isEmpty, !selectedEmotions.isEmpty else { return }

        isGenerating = true
        defer { isGenerating = false }

        do {
            var engine: LLMEngine!
            var result: String

            engine = try await LLMEngine(modelName: modelName)
            result = try await engine.generate(
                diary: diary,
                gender: "남",
                age: 28,
                includeSystemPrompt: enableSystemPrompt
            )

            let entry = DiaryEntry(
                date: entryTimestamp(),
                text: diary,
                weather: selectedWeather,
                valence: valence,
                emotions: Emotion.allCases.filter(selectedEmotions.contains),
                feedback: result
            )
            modelContext.insert(entry)

            userMessage = ""
            isTextFieldFocused = false

            if !hasDisappeared {
                path.removeLast()
                path.append(DiaryRoute.detail(entry))
            }
        } catch {
            logger.error("\(error.localizedDescription, privacy: .public)")
            showsSubmissionError = true
        }
    }

    private func entryTimestamp() -> Date {
        let calendar = Calendar.current
        let timeOfDay = calendar.dateComponents([.hour, .minute, .second], from: .now)
        return calendar.date(
            bySettingHour: timeOfDay.hour ?? 0,
            minute: timeOfDay.minute ?? 0,
            second: timeOfDay.second ?? 0,
            of: calendar.startOfDay(for: date)
        ) ?? date
    }
}

#Preview {
    NavigationStack {
        DiaryWriteScreen(path: .constant(NavigationPath()), date: .now)
    }
}
