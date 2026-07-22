import SwiftUI

struct FastingProgressView: View {
    @Bindable var model: AppModel

    var body: some View {
        ScreenScroll(title: "Progress") {
            Card {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Fasting hours this week")
                        .font(.system(size: 14))
                        .foregroundStyle(NFTheme.secondaryText)
                    WeeklyBars(values: [14, 16, 12, 18, 16, 0, 7])
                }
            }

            Card {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Weight trend")
                            .font(.system(size: 14))
                            .foregroundStyle(NFTheme.secondaryText)
                        Spacer()
                        Text(weightRange)
                            .font(.system(size: 13))
                            .foregroundStyle(NFTheme.tertiaryText)
                    }
                    WeightLine(values: displayLog)
                        .frame(height: 110)
                }
            }

            Card {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Achievements")
                        .font(.system(size: 14))
                        .foregroundStyle(NFTheme.secondaryText)
                    HStack(spacing: 10) {
                        Badge(label: "First Fast", unlocked: true)
                        Badge(label: "7-Day Streak", unlocked: true)
                        Badge(label: "30-Day Streak", unlocked: false)
                        Badge(label: "50 Fasts", unlocked: false)
                    }
                }
            }
        }
    }

    private var displayLog: [Double] {
        model.weightLog.map { model.displayWeight($0) }
    }

    private var weightRange: String {
        guard let min = displayLog.min(), let max = displayLog.max() else { return "--" }
        return "\(min.oneDecimal)-\(max.oneDecimal) \(model.units.weightLabel)"
    }
}

private struct WeeklyBars: View {
    let values: [Double]
    private let labels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(values.indices, id: \.self) { index in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(NFTheme.gradient)
                        .frame(height: max(4, CGFloat(values[index] / 24) * 100))
                    Text(labels[index])
                        .font(.system(size: 11))
                        .foregroundStyle(NFTheme.tertiaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: 120, alignment: .bottom)
            }
        }
    }
}

private struct WeightLine: View {
    let values: [Double]

    var body: some View {
        GeometryReader { proxy in
            Path { path in
                guard let minValue = values.min(), let maxValue = values.max(), values.count > 1 else { return }
                let range = Swift.max(maxValue - minValue, 1)
                let width = proxy.size.width
                let height = proxy.size.height
                for (index, value) in values.enumerated() {
                    let x = CGFloat(index) / CGFloat(values.count - 1) * width
                    let y = height - CGFloat((value - minValue) / range) * height
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(NFTheme.accentTwo, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        }
    }
}

private struct Badge: View {
    let label: String
    let unlocked: Bool

    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(unlocked ? NFTheme.accent : .white.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: unlocked ? "checkmark" : "lock")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(unlocked ? .white : NFTheme.tertiaryText)
                )
            Text(label)
                .font(.system(size: 9.5))
                .foregroundStyle(NFTheme.tertiaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
}
