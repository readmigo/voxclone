import SwiftUI

struct ResultView: View {
    let greetingTask: GreetingTask
    let onRestart: () -> Void

    @StateObject private var combinedPlayerService = AudioPlayerService()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("🎉")
                        .font(.system(size: 60))

                    Text("祝福生成完成!")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.top, 16)

                if let combinedUrl = greetingTask.combinedAudioUrl {
                    combinedAudioCard(urlString: combinedUrl)
                }

                Divider()
                    .padding(.horizontal, 24)

                if let results = greetingTask.results {
                    VStack(spacing: 12) {
                        Text("各语言版本")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)

                        ForEach(results) { result in
                            AudioPlayerView(
                                dialectName: result.dialectName,
                                emoji: emojiForDialect(result.dialect),
                                text: result.text,
                                audioUrl: result.audioUrl
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                }

                VStack(spacing: 12) {
                    if let combinedUrl = greetingTask.combinedAudioUrl,
                       let url = URL(string: combinedUrl) {
                        Button {
                            Task {
                                await saveAudio(from: url)
                            }
                        } label: {
                            Label("保存音频", systemImage: "square.and.arrow.down")
                                .font(.headline)
                                .foregroundStyle(Color.accentGradientStart)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.accentGradientStart.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        Button {
                            Task {
                                await ShareService.share(audioURLString: combinedUrl)
                            }
                        } label: {
                            Label("分享给朋友", systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.accentGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }

                    Button {
                        onRestart()
                    } label: {
                        Label("再来一次", systemImage: "arrow.counterclockwise")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    @ViewBuilder
    private func combinedAudioCard(urlString: String) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("🎵")
                    .font(.title2)
                Text("完整版")
                    .font(.headline)
                    .foregroundStyle(Color.accentGradientStart)
                Spacer()
            }

            HStack(spacing: 16) {
                Button {
                    toggleCombinedPlayback(urlString: urlString)
                } label: {
                    Image(systemName: combinedPlayerService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.accentGradientStart)
                }

                VStack(spacing: 4) {
                    ProgressView(value: combinedPlayerService.currentTime, total: max(combinedPlayerService.duration, 0.01))
                        .tint(Color.accentGradientStart)

                    HStack {
                        Text(formatTime(combinedPlayerService.currentTime))
                        Spacer()
                        Text(formatTime(combinedPlayerService.duration))
                    }
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.accentGradientStart.opacity(0.08), Color.accentGradientEnd.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.accentGradientStart.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }

    private func toggleCombinedPlayback(urlString: String) {
        if combinedPlayerService.isPlaying {
            combinedPlayerService.pause()
        } else if let url = URL(string: urlString) {
            combinedPlayerService.play(url: url)
        }
    }

    private func saveAudio(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("dialect_blessing_\(UUID().uuidString).m4a")
            try data.write(to: fileURL)
        } catch {
            print("Failed to save audio: \(error)")
        }
    }

    private func emojiForDialect(_ dialect: String) -> String {
        Dialect(rawValue: dialect)?.emoji ?? "🗣️"
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
