import UIKit

struct ShareService {
    @MainActor
    static func share(audioURLString: String) async {
        guard let remoteURL = URL(string: audioURLString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: remoteURL)
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("blessing_\(UUID().uuidString).m4a")
            try data.write(to: tempURL)

            let activityVC = UIActivityViewController(
                activityItems: [tempURL],
                applicationActivities: nil
            )

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else {
                return
            }

            rootVC.present(activityVC, animated: true)
        } catch {
            print("Failed to share audio: \(error)")
        }
    }

    @MainActor
    static func share(localURL: URL) {
        let activityVC = UIActivityViewController(
            activityItems: [localURL],
            applicationActivities: nil
        )

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }

        rootVC.present(activityVC, animated: true)
    }
}
