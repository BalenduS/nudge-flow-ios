import SwiftUI

struct TrackView: View {
    @Bindable var model: AppModel

    var body: some View {
        ScreenScroll(title: "Track") {
            waterCard
            weightCard
            moodCard
        }
    }

    private var waterCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Water")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text("\(model.water) / 8 glasses")
                        .font(.system(size: 13))
                        .foregroundStyle(NFTheme.secondaryText)
                }

                HStack(spacing: 8) {
                    ForEach(0..<8, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(index < model.water ? NFTheme.accent : .clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .stroke(NFTheme.accent, lineWidth: 1.5)
                            )
                            .frame(width: 28, height: 36)
                    }
                }

                HStack(spacing: 10) {
                    TrackerButton(title: "-") { model.adjustWater(by: -1) }
                    TrackerButton(title: "+", prominent: true) { model.adjustWater(by: 1) }
                }
            }
        }
    }

    private var weightCard: some View {
        Card {
            VStack(spacing: 16) {
                HStack {
                    Text("Weight")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text("\(model.displayWeight().oneDecimal) \(model.units.weightLabel)")
                        .font(.system(size: 20, weight: .black))
                }

                HStack(spacing: 10) {
                    TrackerButton(title: "- 0.1") {
                        model.adjustWeight(by: model.units == .metric ? -0.1 : -0.5 / 2.20462)
                    }
                    TrackerButton(title: "+ 0.1", prominent: true) {
                        model.adjustWeight(by: model.units == .metric ? 0.1 : 0.5 / 2.20462)
                    }
                }
            }
        }
    }

    private var moodCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                Text("How do you feel?")
                    .font(.system(size: 15, weight: .semibold))
                HStack {
                    ForEach(Mood.allCases) { mood in
                        Button {
                            model.mood = mood
                        } label: {
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(color(for: mood))
                                    .frame(width: 38, height: 38)
                                    .overlay(Circle().stroke(model.mood == mood ? NFTheme.accent : .clear, lineWidth: 3))
                                Text(mood.rawValue)
                                    .font(.system(size: 10.5))
                                    .foregroundStyle(NFTheme.tertiaryText)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func color(for mood: Mood) -> Color {
        switch mood {
        case .great: Color(red: 0.55, green: 0.48, blue: 0.91)
        case .good: Color(red: 0.65, green: 0.55, blue: 0.98)
        case .okay: Color(red: 0.77, green: 0.71, blue: 0.99)
        case .low: Color(red: 0.61, green: 0.56, blue: 0.81)
        case .bad: Color(red: 0.44, green: 0.37, blue: 0.66)
        }
    }
}

private struct TrackerButton: View {
    let title: String
    var prominent = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(prominent ? NFTheme.accent : .white.opacity(0.08))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
