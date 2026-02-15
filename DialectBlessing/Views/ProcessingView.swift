import SwiftUI

struct ProcessingView: View {
    @State private var progress: Double = 0
    @State private var dotCount = 0

    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color.accentGradientStart, Color.accentGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "waveform")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.accentGradientStart)
                    .symbolEffect(.variableColor.iterative, options: .repeating)
            }

            VStack(spacing: 12) {
                Text("正在用AI为您生成方言祝福\(String(repeating: ".", count: dotCount))")
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text("预计需要30-60秒，请耐心等待")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("\(Int(progress * 100))%")
                .font(.system(size: 24, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.accentGradientStart)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.8)) {
                if progress < 0.95 {
                    progress += Double.random(in: 0.01...0.03)
                }
            }
            dotCount = (dotCount + 1) % 4
        }
    }
}
