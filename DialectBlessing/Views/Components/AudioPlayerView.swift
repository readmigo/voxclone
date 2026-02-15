import SwiftUI

struct AudioPlayerView: View {
    let dialectName: String
    let emoji: String
    let text: String
    let audioUrl: String

    @StateObject private var playerService = AudioPlayerService()
    @State private var isTextExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.title2)

                Text(dialectName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    togglePlayback()
                } label: {
                    Image(systemName: playerService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.accentGradientStart)
                }

                if playerService.duration > 0 {
                    Text(formatTime(playerService.currentTime))
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .frame(width: 40)
                }
            }

            if playerService.duration > 0 {
                ProgressView(value: playerService.currentTime, total: max(playerService.duration, 0.01))
                    .tint(Color.accentGradientStart)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isTextExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(text)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(isTextExpanded ? nil : 1)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: isTextExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private func togglePlayback() {
        if playerService.isPlaying {
            playerService.pause()
        } else if let url = URL(string: audioUrl) {
            playerService.play(url: url)
        }
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
