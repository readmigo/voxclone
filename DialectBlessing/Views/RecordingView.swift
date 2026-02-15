import SwiftUI

struct RecordingView: View {
    @ObservedObject var recorderService: AudioRecorderService
    let onNext: () -> Void

    @StateObject private var playerService = AudioPlayerService()
    @State private var isPulsing = false
    @State private var promptIndex = Int.random(in: 0..<readingPrompts.count)

    private static let readingPrompts: [String] = [
        "今天天气真不错，阳光明媚，微风轻拂。让我们一起出发，去感受这个美好的世界吧。",
        "春风送暖入屠苏，千门万户曈曈日。总把新桃换旧符，愿你新年快乐，万事如意。",
        "海上生明月，天涯共此时。远方的朋友，无论你在哪里，都请记得有人在想念你。",
        "生活就像一杯茶，不会苦一辈子，但总会苦一阵子。保持微笑，好运自然来。",
        "白日依山尽，黄河入海流。欲穷千里目，更上一层楼。祝你步步高升，前程似锦。",
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("录制你的声音")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 16)

            Text("请朗读以下文本，AI将学习你的音色")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // 朗读文本卡片
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "text.quote")
                        .foregroundStyle(Color.accentGradientStart)
                    Text("请朗读")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            promptIndex = (promptIndex + 1) % Self.readingPrompts.count
                        }
                    } label: {
                        Label("换一段", systemImage: "arrow.triangle.2.circlepath")
                            .font(.caption)
                            .foregroundStyle(Color.accentGradientStart)
                    }
                    .disabled(recorderService.isRecording)
                }

                Text(Self.readingPrompts[promptIndex])
                    .font(.title3)
                    .fontWeight(.medium)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .id(promptIndex)
                    .transition(.opacity)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        recorderService.isRecording
                            ? Color.accentGradientStart.opacity(0.4)
                            : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .padding(.horizontal, 24)

            WaveformView(isAnimating: recorderService.isRecording)
                .padding(.horizontal, 40)

            Text(formatTime(recorderService.recordingTime))
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .foregroundStyle(recorderService.isRecording ? Color.accentGradientStart : .secondary)

            Spacer()

            if recorderService.hasRecording && !recorderService.isRecording {
                recordingCompleteControls
            } else {
                recordButton
            }

            Spacer()

            Button {
                onNext()
            } label: {
                Text("下一步")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        recorderService.hasRecording
                            ? AnyShapeStyle(Color.accentGradient)
                            : AnyShapeStyle(Color.gray.opacity(0.3))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(!recorderService.hasRecording)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    private var recordButton: some View {
        Button {
            if recorderService.isRecording {
                recorderService.stopRecording()
            } else {
                recorderService.startRecording()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentGradientStart, Color.accentGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(isPulsing ? 1.1 : 1.0)
                    .shadow(color: Color.accentGradientStart.opacity(0.4), radius: isPulsing ? 16 : 8)

                Image(systemName: recorderService.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
            }
        }
        .onChange(of: recorderService.isRecording) { _, isRecording in
            if isRecording {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPulsing = false
                }
            }
        }
    }

    private var recordingCompleteControls: some View {
        HStack(spacing: 32) {
            Button {
                if let url = recorderService.audioURL {
                    if playerService.isPlaying {
                        playerService.stop()
                    } else {
                        playerService.play(url: url)
                    }
                }
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: playerService.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.accentGradientStart)
                    Text("试听")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                playerService.stop()
                recorderService.deleteRecording()
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)
                    Text("重新录音")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let tenths = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }
}
