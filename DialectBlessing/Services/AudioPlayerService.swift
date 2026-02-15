import AVFoundation
import Foundation

@MainActor
final class AudioPlayerService: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0

    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?

    func play(url: URL) {
        stop()

        if url.scheme == "http" || url.scheme == "https" {
            Task {
                await downloadAndPlay(url: url)
            }
            return
        }

        startPlayback(url: url)
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTime = 0
        timer?.invalidate()
        timer = nil
    }

    private func downloadAndPlay(url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("playback_\(UUID().uuidString).m4a")
            try data.write(to: tempURL)
            startPlayback(url: tempURL)
        } catch {
            print("Failed to download audio: \(error)")
        }
    }

    private func startPlayback(url: URL) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            duration = audioPlayer?.duration ?? 0
            audioPlayer?.play()
            isPlaying = true

            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    self.currentTime = self.audioPlayer?.currentTime ?? 0
                }
            }
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
}

extension AudioPlayerService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
            currentTime = 0
            timer?.invalidate()
            timer = nil
        }
    }
}
