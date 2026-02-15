import SwiftUI

struct StepIndicator: View {
    let currentStep: Int
    let steps = ["录音", "主题", "方言", "结果"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<steps.count, id: \.self) { index in
                HStack(spacing: 0) {
                    stepCircle(for: index)

                    if index < steps.count - 1 {
                        Rectangle()
                            .fill(index < currentStep ? Color.accentGradientStart : Color.gray.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func stepCircle(for index: Int) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(circleColor(for: index))
                    .frame(width: 32, height: 32)

                if index < currentStep {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(index == currentStep ? .white : .gray)
                }
            }

            Text(steps[index])
                .font(.caption2)
                .foregroundStyle(index <= currentStep ? Color.accentGradientStart : .gray)
        }
    }

    private func circleColor(for index: Int) -> Color {
        if index < currentStep {
            return Color.accentGradientStart
        } else if index == currentStep {
            return Color.accentGradientEnd
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

extension Color {
    static let accentGradientStart = Color(red: 229 / 255, green: 57 / 255, blue: 53 / 255)
    static let accentGradientEnd = Color(red: 255 / 255, green: 109 / 255, blue: 0 / 255)
    static let accentGradient = LinearGradient(
        colors: [accentGradientStart, accentGradientEnd],
        startPoint: .leading,
        endPoint: .trailing
    )
}
