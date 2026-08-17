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

    private let feedbackService = DiaryFeedbackService()

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "simjang",
        category: "Performance"
    )

    var body: some View {
        content
            .id(step)
            .transition(.opacity)
            .padding()
            .animation(.easeInOut(duration: 0.2), value: step)
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
            .statusBarHidden(true)
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
        VStack(alignment: .leading, spacing: 60) {
            Spacer()
            Text("오늘의 하늘을 떠올려보세요")
                .font(.diaryTitle)
            HStack(spacing: 4) {
                ForEach(Weather.allCases) { weather in
                    Button {
                        selectedWeather = selectedWeather == weather ? nil : weather
                        step = .valence
                    } label: {
                        Image(weather.iconName)
                            .renderingMode(.template)
                            .foregroundStyle(selectedWeather == weather ? Color.accentForeground : Color.appForeground)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .accessibilityLabel(weather.displayName)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(selectedWeather == weather ? .accent : .accentMuted)
                    .animation(
                        .easeInOut(duration: 0.2),
                        value: selectedWeather == weather
                    )
                    .accessibilityAddTraits(
                        selectedWeather == weather ? .isSelected : []
                    )
                }
            }
            Spacer()
        }
    }

    private var valenceStep: some View {
        VStack(alignment: .leading, spacing: 60) {
            Spacer()
            Text("오늘의 마음은 어떤가요?")
                .font(.diaryTitle)

            Text(valence.displayName)
                .font(.diaryHeadline)
                .frame(maxWidth: .infinity, alignment: .center)

            Slider(value: $valenceValue, in: -3...3) {
                Text("오늘의 기분")
            } minimumValueLabel: {
                Text("불쾌")
            } maximumValueLabel: {
                Text("상쾌")
            }.tint(.accent)
            Spacer()

            Button("다음") {
                step = .emotions
            }
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
            .controlSize(.large)
            .tint(.taupe700)
            .foregroundStyle(Color.neutral50)
        }
    }

    private var emotionStep: some View {
        let matchingEmotions = valence.emotionValence.emotions

        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(valence.displayName)
                    .font(.diaryHeadline)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
                
                Text("어떤 감정을 느꼈나요?")
                    .font(.diaryTitle)

                FlowLayout(spacing: 8) {
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
                        .tint(.accent)
                        .font(.diaryCaption)
                }

                Button("다음") {
                    step = .diary
                }
                .buttonStyle(.glassProminent)
                .buttonSizing(.flexible)
                .disabled(selectedEmotions.isEmpty)
                .controlSize(.large)
                .tint(.taupe700)
                .font(.diaryRegular)
                .foregroundStyle(Color.neutral50)
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
                .font(.diaryHeadline.pointSize(13))
                .foregroundStyle(isSelected ? Color.accentForeground : Color.appForeground)
        }
        .buttonStyle(.borderedProminent)
        .buttonSizing(.fitted)
        .tint(isSelected ? .accent : .accentMuted)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var diaryStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            ZStack(alignment: .topLeading) {
                if userMessage.isEmpty {
                    Text("오늘 있었던 일을 적어보세요")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $userMessage)
                    .focused($isTextFieldFocused)
                    .scrollContentBackground(.hidden)
            }
            .font(.diaryBody)
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

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
                        .font(.diaryRegular)
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
            .tint(.taupe700)
            .foregroundStyle(Color.neutral50)
        }
    }

    @MainActor
    private func submit() async {
        let diary = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !diary.isEmpty, !selectedEmotions.isEmpty else { return }

        isGenerating = true
        defer { isGenerating = false }

        do {
            let entry = DiaryEntry(
                date: entryTimestamp(),
                text: diary,
                weather: selectedWeather,
                valence: valence,
                emotions: Emotion.allCases.filter(selectedEmotions.contains)
            )
            modelContext.insert(entry)
            try modelContext.save()

            let result = try await feedbackService.generate(
                for: entry,
                includeSystemPrompt: enableSystemPrompt
            )

            entry.feedback = result
            try modelContext.save()

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
