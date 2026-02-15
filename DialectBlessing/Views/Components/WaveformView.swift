import SwiftUI

struct WaveformView: View {
    let isAnimating: Bool
    let barCount: Int

    @State private var animationPhases: [CGFloat]

    init(isAnimating: Bool, barCount: Int = 20) {
        self.isAnimating = isAnimating
        self.barCount = barCount
        _animationPhases = State(initialValue: (0..<barCount).map { _ in CGFloat.random(in: 0.2...1.0) })
    }

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentGradient)
                    .frame(width: 4, height: barHeight(for: index))
            }
        }
        .frame(height: 60)
        .onChange(of: isAnimating) { _, newValue in
            if newValue {
                startAnimating()
            }
        }
        .onAppear {
            if isAnimating {
                startAnimating()
            }
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        if isAnimating {
            return animationPhases[index] * 60
        } else {
            return 8
        }
    }

    private func startAnimating() {
        guard isAnimating else { return }
        withAnimation(
            .easeInOut(duration: 0.4)
            .repeatForever(autoreverses: true)
        ) {
            animationPhases = (0..<barCount).map { _ in CGFloat.random(in: 0.2...1.0) }
        }

        scheduleNextUpdate()
    }

    private func scheduleNextUpdate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            guard isAnimating else { return }
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                animationPhases = (0..<barCount).map { _ in CGFloat.random(in: 0.2...1.0) }
            }
            scheduleNextUpdate()
        }
    }
}
