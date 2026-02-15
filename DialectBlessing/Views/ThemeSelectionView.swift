import SwiftUI

struct ThemeSelectionView: View {
    @Binding var selectedFestival: Festival?
    @Binding var customText: String
    let onNext: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("选择祝福主题")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 24)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Festival.presets) { festival in
                        FestivalCard(
                            festival: festival,
                            isSelected: selectedFestival?.id == festival.id
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedFestival = festival
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text("自定义祝福语")
                        .font(.headline)
                        .padding(.horizontal, 24)

                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $customText)
                            .frame(minHeight: 100)
                            .padding(12)
                            .scrollContentBackground(.hidden)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .onChange(of: customText) { _, newValue in
                                if newValue.count > 100 {
                                    customText = String(newValue.prefix(100))
                                }
                            }

                        if customText.isEmpty {
                            Text("输入你想说的祝福，比如：新年快乐，万事如意")
                                .foregroundStyle(.tertiary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 20)
                                .allowsHitTesting(false)
                        }
                    }
                    .padding(.horizontal, 24)

                    HStack {
                        Spacer()
                        Text("\(customText.count)/100")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 28)
                }

                Button {
                    onNext()
                } label: {
                    Text("下一步")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .padding(.top, 8)
        }
    }
}

private struct FestivalCard: View {
    let festival: Festival
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(festival.emoji)
                    .font(.system(size: 40))

                Text(festival.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.accentGradientStart : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
