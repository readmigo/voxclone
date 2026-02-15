import SwiftUI

struct ContentView: View {
    @State private var currentStep: Int = 0
    @StateObject private var recorderService = AudioRecorderService()

    @State private var selectedFestival: Festival?
    @State private var customText: String = ""
    @State private var selectedDialects: Set<Dialect> = Dialect.defaultSelection
    @State private var greetingResult: GreetingTask?
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        VStack(spacing: 0) {
            if currentStep < 4 {
                StepIndicator(currentStep: currentStep)
            }

            Group {
                switch currentStep {
                case 0:
                    RecordingView(recorderService: recorderService) {
                        withAnimation { currentStep = 1 }
                    }
                case 1:
                    ThemeSelectionView(
                        selectedFestival: $selectedFestival,
                        customText: $customText
                    ) {
                        withAnimation { currentStep = 2 }
                    }
                case 2:
                    DialectSelectionView(selectedDialects: $selectedDialects) {
                        withAnimation { currentStep = 3 }
                        startGeneration()
                    }
                case 3:
                    ProcessingView()
                case 4:
                    if let result = greetingResult {
                        ResultView(greetingTask: result) {
                            resetAll()
                        }
                    }
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .alert("出错了", isPresented: $showError) {
            Button("重试") {
                withAnimation { currentStep = 2 }
            }
            Button("取消", role: .cancel) {
                withAnimation { currentStep = 0 }
            }
        } message: {
            Text(errorMessage ?? "未知错误")
        }
    }

    private func startGeneration() {
        Task {
            do {
                guard let audioURL = recorderService.audioURL else {
                    throw APIError.serverError
                }

                let theme = selectedFestival?.id ?? "custom"
                let taskId = try await APIService.shared.generateGreeting(
                    audioURL: audioURL,
                    theme: theme,
                    customText: customText,
                    dialects: Array(selectedDialects)
                )

                let result = try await APIService.shared.pollUntilComplete(taskId: taskId)
                greetingResult = result

                withAnimation {
                    currentStep = 4
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func resetAll() {
        withAnimation {
            currentStep = 0
        }
        recorderService.deleteRecording()
        selectedFestival = nil
        customText = ""
        selectedDialects = Dialect.defaultSelection
        greetingResult = nil
        errorMessage = nil
    }
}
