import SwiftUI

struct DialectSelectionView: View {
    @Binding var selectedDialects: Set<Dialect>
    let onGenerate: () -> Void

    private var allChineseSelected: Bool {
        Dialect.chineseDialects.allSatisfy { selectedDialects.contains($0) }
    }

    private var allInternationalSelected: Bool {
        Dialect.internationalLanguages.allSatisfy { selectedDialects.contains($0) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("选择语言")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 24)

                Text("选择你想要生成的方言/语言祝福")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 24)

                // 中文方言组
                dialectSection(
                    title: "🇨🇳 中文方言",
                    dialects: Dialect.chineseDialects,
                    allSelected: allChineseSelected,
                    toggleAll: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if allChineseSelected {
                                Dialect.chineseDialects.forEach { selectedDialects.remove($0) }
                            } else {
                                Dialect.chineseDialects.forEach { selectedDialects.insert($0) }
                            }
                        }
                    }
                )

                // 国际语言组
                dialectSection(
                    title: "🌍 国际语言",
                    dialects: Dialect.internationalLanguages,
                    allSelected: allInternationalSelected,
                    toggleAll: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if allInternationalSelected {
                                Dialect.internationalLanguages.forEach { selectedDialects.remove($0) }
                            } else {
                                Dialect.internationalLanguages.forEach { selectedDialects.insert($0) }
                            }
                        }
                    }
                )

                Button {
                    onGenerate()
                } label: {
                    Text("生成祝福 (\(selectedDialects.count)种)")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            selectedDialects.isEmpty
                                ? AnyShapeStyle(Color.gray.opacity(0.3))
                                : AnyShapeStyle(
                                    LinearGradient(
                                        colors: [Color.accentGradientStart, Color.accentGradientEnd],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(selectedDialects.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .padding(.top, 8)
        }
    }

    @ViewBuilder
    private func dialectSection(
        title: String,
        dialects: [Dialect],
        allSelected: Bool,
        toggleAll: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    toggleAll()
                } label: {
                    Text(allSelected ? "取消全选" : "全选")
                        .font(.subheadline)
                        .foregroundStyle(Color.accentGradientStart)
                }
            }
            .padding(.horizontal, 24)

            ForEach(dialects) { dialect in
                DialectCard(
                    dialect: dialect,
                    isSelected: selectedDialects.contains(dialect)
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if selectedDialects.contains(dialect) {
                            selectedDialects.remove(dialect)
                        } else {
                            selectedDialects.insert(dialect)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

private struct DialectCard: View {
    let dialect: Dialect
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(dialect.emoji)
                    .font(.title)

                VStack(alignment: .leading, spacing: 4) {
                    Text(dialect.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(dialect.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle("", isOn: .constant(isSelected))
                    .labelsHidden()
                    .tint(Color.accentGradientStart)
                    .allowsHitTesting(false)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.accentGradientStart.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }
}
