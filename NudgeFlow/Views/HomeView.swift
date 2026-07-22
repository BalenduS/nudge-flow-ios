import SwiftUI

struct HomeView: View {
    @Bindable var model: AppModel
    @State private var now = Date()

    var body: some View {
        ScreenScroll(title: nil) {
            header
            timerPanel
            StageTracker(elapsedHours: elapsedHours)
            statsRow
        }
        .task {
            while !Task.isCancelled {
                now = .now
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 14))
                    .foregroundStyle(NFTheme.tertiaryText)
                Text("Let's fast, \(model.displayName)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(NFTheme.text)
            }
            Spacer()
            Text(model.avatarInitial)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(NFTheme.gradient)
                .clipShape(Circle())
        }
    }

    private var timerPanel: some View {
        VStack(spacing: 18) {
            ProgressRing(progress: progress, elapsed: elapsedString, stage: stageLabel, plan: model.selectedPlan.rawValue)

            if model.fasting.active {
                HStack(spacing: 28) {
                    timeLabel(title: "Started", value: model.fasting.startedAt?.formatted(date: .omitted, time: .shortened) ?? "--")
                    timeLabel(title: "Goal", value: goalDate.formatted(date: .omitted, time: .shortened))
                }

                Button {
                    model.endFast()
                } label: {
                    Text("End Fast")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(NFTheme.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(.white.opacity(0.08))
                        .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 1))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            } else {
                GradientButton(title: "Start Fast") {
                    model.startFast()
                }
            }
        }
        .padding(.vertical, 10)
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            MiniStat(value: "5", label: "Day streak")
            MiniStat(value: "42", label: "Total fasts")
            MiniStat(value: "15.6h", label: "Avg length")
        }
    }

    private func timeLabel(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(NFTheme.tertiaryText)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(NFTheme.text)
        }
    }

    private var elapsed: TimeInterval {
        guard model.fasting.active, let startedAt = model.fasting.startedAt else { return 0 }
        return max(0, now.timeIntervalSince(startedAt))
    }

    private var elapsedHours: Double { elapsed / 3600 }
    private var totalSeconds: Double { Double(model.fasting.active ? model.fasting.planHours : model.selectedPlan.fastHours) * 3600 }
    private var progress: Double { min(1, max(0, elapsed / totalSeconds)) }
    private var goalDate: Date { (model.fasting.startedAt ?? now).addingTimeInterval(totalSeconds) }

    private var elapsedString: String {
        let total = Int(elapsed)
        return String(format: "%02d:%02d:%02d", total / 3600, (total % 3600) / 60, total % 60)
    }

    private var stageLabel: String {
        Stage.current(for: elapsedHours).label
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: now)
        if hour < 12 { return "Good morning" }
        if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }
}

private struct ProgressRing: View {
    let progress: Double
    let elapsed: String
    let stage: String
    let plan: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.07), lineWidth: 14)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(NFTheme.gradient, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 5) {
                Text(elapsed)
                    .font(.system(size: 28, weight: .black))
                    .monospacedDigit()
                    .foregroundStyle(NFTheme.text)
                Text(stage)
                    .font(.system(size: 12, weight: .medium))
                    .textCase(.uppercase)
                    .tracking(0.6)
                    .foregroundStyle(NFTheme.tertiaryText)
                Text("\(plan) Plan · \(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(NFTheme.accentTwo)
            }
        }
        .frame(width: 220, height: 220)
        .frame(maxWidth: .infinity)
    }
}

private struct StageTracker: View {
    let elapsedHours: Double
    private let stages = Stage.all

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(stages) { stage in
                VStack(spacing: 6) {
                    Circle()
                        .fill(stage.id == Stage.current(for: elapsedHours).id ? NFTheme.accent : .white.opacity(0.1))
                        .frame(width: 10, height: 10)
                        .shadow(color: NFTheme.accent.opacity(stage.id == Stage.current(for: elapsedHours).id ? 0.55 : 0), radius: 8)
                    Text(stage.label)
                        .font(.system(size: 10))
                        .foregroundStyle(NFTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 6)
    }
}

private struct MiniStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(NFTheme.text)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(NFTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(NFTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct Stage: Identifiable {
    let id: Int
    let hours: Double
    let label: String

    static let all = [
        Stage(id: 0, hours: 0, label: "Fed State"),
        Stage(id: 1, hours: 4, label: "Fat Burning"),
        Stage(id: 2, hours: 12, label: "Ketosis"),
        Stage(id: 3, hours: 16, label: "Fat Loss"),
        Stage(id: 4, hours: 24, label: "Autophagy")
    ]

    static func current(for elapsedHours: Double) -> Stage {
        all.last { elapsedHours >= $0.hours } ?? all[0]
    }
}
