import SwiftUI

struct HomeView: View {
    @Bindable var model: AppModel
    @State private var now = Date()
    @State private var editingStartTime = false
    @State private var draftStartTime = Date()

    var body: some View {
        ZStack {
            homeBackground

            ScrollView {
                VStack(spacing: 18) {
                    header
                    fastHero
                    StageJourney(elapsedHours: elapsedHours)
                    statsRow
                    encouragementCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
        }
        .task {
            while !Task.isCancelled {
                now = .now
                try? await Task.sleep(for: .seconds(1))
            }
        }
        .sheet(isPresented: $editingStartTime) {
            EditFastStartView(startTime: $draftStartTime) {
                model.updateFastStartTime(draftStartTime)
                FastingNotificationScheduler.scheduleStageNotifications(startedAt: draftStartTime, planHours: model.fasting.planHours)
                editingStartTime = false
            } cancel: {
                editingStartTime = false
            }
            .presentationDetents([.height(300)])
        }
    }

    private var homeBackground: some View {
        ZStack {
            NFTheme.background.ignoresSafeArea()
            LinearGradient(
                colors: [NFTheme.accent.opacity(0.22), .clear, NFTheme.background],
                startPoint: .topTrailing,
                endPoint: .center
            )
            .ignoresSafeArea()
            LinearGradient(
                colors: [.clear, NFTheme.surface.opacity(0.68)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NFTheme.secondaryText)
                Text(model.fasting.active ? "Stay with it, \(model.displayName)" : "Ready, \(model.displayName)?")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(NFTheme.text)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }

            Spacer()

            Text(model.avatarInitial)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(NFTheme.gradient)
                .clipShape(Circle())
                .shadow(color: NFTheme.accent.opacity(0.35), radius: 18, y: 8)
        }
    }

    private var fastHero: some View {
        VStack(spacing: 18) {
            HStack {
                Label(model.selectedPlan.rawValue, systemImage: "sparkles")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(NFTheme.gradient)
                    .clipShape(Capsule())

                Spacer()

                Text(model.fasting.active ? "Fasting now" : "Next fast")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(NFTheme.secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.08))
                    .clipShape(Capsule())
            }

            ProgressRing(
                progress: progress,
                elapsed: elapsedString,
                stage: stageLabel,
                plan: model.selectedPlan.rawValue,
                headline: model.fasting.active ? nextMilestoneText : "Build today’s rhythm"
            )

            if model.fasting.active {
                HStack(spacing: 10) {
                    Button {
                        draftStartTime = model.fasting.startedAt ?? now
                        editingStartTime = true
                    } label: {
                        TimeMetric(title: "Started", value: model.fasting.startedAt?.formatted(date: .omitted, time: .shortened) ?? "--", symbol: "pencil")
                    }
                    .buttonStyle(.plain)

                    TimeMetric(title: "Goal", value: goalDate.formatted(date: .omitted, time: .shortened), symbol: "flag.checkered")
                    TimeMetric(title: "Left", value: remainingString, symbol: "hourglass")
                }

                Button {
                    model.endFast()
                    FastingNotificationScheduler.cancelStageNotifications()
                } label: {
                    Label("End Fast", systemImage: "stop.circle")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(NFTheme.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(.white.opacity(0.09))
                        .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 1))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            } else {
                VStack(spacing: 12) {
                    Text("Start now and we’ll nudge you at every stage.")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(NFTheme.secondaryText)
                        .multilineTextAlignment(.center)

                    GradientButton(title: "Start Fast") {
                        startFast(at: .now)
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [NFTheme.surfaceRaised, NFTheme.surface, NFTheme.accent.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.28), radius: 26, y: 18)
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            MiniStat(value: "5", label: "Day streak", symbol: "flame.fill")
            MiniStat(value: "42", label: "Total fasts", symbol: "checkmark.seal.fill")
            MiniStat(value: "15.6h", label: "Avg length", symbol: "chart.line.uptrend.xyaxis")
        }
    }

    private var encouragementCard: some View {
        HStack(spacing: 14) {
            Image(systemName: model.fasting.active ? "bell.badge.fill" : "bolt.heart.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(NFTheme.accent)
                .frame(width: 46, height: 46)
                .background(NFTheme.accent.opacity(0.14))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(model.fasting.active ? currentStage.encouragement : "A calm start beats a perfect start.")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(NFTheme.text)
                Text(model.fasting.active ? "Next stage: \(nextStage?.label ?? "Plan complete")" : "Begin when your last meal feels settled.")
                    .font(.system(size: 13))
                    .foregroundStyle(NFTheme.secondaryText)
            }

            Spacer()
        }
        .padding(16)
        .background(NFTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func startFast(at date: Date) {
        model.startFast(now: date)
        Task {
            await FastingNotificationScheduler.requestAuthorization()
            FastingNotificationScheduler.scheduleStageNotifications(startedAt: date, planHours: model.selectedPlan.fastHours)
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
    private var currentStage: FastingStage { FastingStage.current(for: elapsedHours) }
    private var stageLabel: String { currentStage.label }

    private var nextStage: FastingStage? {
        FastingStage.all.first { $0.hours > elapsedHours && $0.hours <= Double(model.fasting.active ? model.fasting.planHours : model.selectedPlan.fastHours) }
    }

    private var nextMilestoneText: String {
        guard let nextStage else { return "Plan complete. Finish with care." }
        let hoursLeft = max(0, nextStage.hours - elapsedHours)
        let totalMinutes = Int((hoursLeft * 60).rounded(.up))
        return "\(nextStage.label) in \(totalMinutes / 60)h \(totalMinutes % 60)m"
    }

    private var remainingString: String {
        let remaining = max(0, totalSeconds - elapsed)
        let totalMinutes = Int(remaining / 60)
        if totalMinutes >= 60 {
            return "\(totalMinutes / 60)h \(totalMinutes % 60)m"
        }
        return "\(totalMinutes)m"
    }

    private var elapsedString: String {
        let total = Int(elapsed)
        return String(format: "%02d:%02d:%02d", total / 3600, (total % 3600) / 60, total % 60)
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
    let headline: String

    var body: some View {
        ZStack {
            Circle()
                .fill(NFTheme.background.opacity(0.62))
                .frame(width: 260, height: 260)

            Circle()
                .stroke(.white.opacity(0.07), lineWidth: 18)
                .frame(width: 232, height: 232)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(NFTheme.gradient, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .frame(width: 232, height: 232)
                .rotationEffect(.degrees(-90))
                .shadow(color: NFTheme.accent.opacity(progress > 0 ? 0.42 : 0.12), radius: 18)

            VStack(spacing: 7) {
                Text(headline)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(NFTheme.accentTwo)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .frame(width: 150)

                Text(elapsed)
                    .font(.system(size: 34, weight: .black))
                    .monospacedDigit()
                    .foregroundStyle(NFTheme.text)

                Text(stage)
                    .font(.system(size: 12, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundStyle(NFTheme.secondaryText)

                Text("\(plan) Plan · \(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(NFTheme.accent)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 270)
    }
}

private struct TimeMetric: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(NFTheme.accent)
            Text(value)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(NFTheme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(NFTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct StageJourney: View {
    let elapsedHours: Double
    private let stages = FastingStage.all

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Fasting journey")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(NFTheme.text)
                Spacer()
                Text(FastingStage.current(for: elapsedHours).label)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(NFTheme.accent)
            }

            HStack(spacing: 8) {
                ForEach(stages) { stage in
                    let reached = elapsedHours >= stage.hours
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(reached ? AnyShapeStyle(NFTheme.gradient) : AnyShapeStyle(.white.opacity(0.09)))
                            .frame(height: 8)
                        Text(stage.label)
                            .font(.system(size: 9.5, weight: reached ? .bold : .medium))
                            .foregroundStyle(reached ? NFTheme.text : NFTheme.tertiaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                            .frame(height: 28, alignment: .top)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(NFTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct EditFastStartView: View {
    @Binding var startTime: Date
    var save: () -> Void
    var cancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Edit start time")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(NFTheme.text)
                    Text("Stage reminders will be recalculated from this time.")
                        .font(.system(size: 13))
                        .foregroundStyle(NFTheme.secondaryText)
                }
                Spacer()
                Button(action: cancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(NFTheme.secondaryText)
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.08))
                        .clipShape(Circle())
                }
            }

            DatePicker("Started at", selection: $startTime, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .tint(NFTheme.accent)
                .foregroundStyle(NFTheme.text)

            GradientButton(title: "Save Start Time", action: save)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(NFTheme.background)
        .preferredColorScheme(.dark)
    }
}

private struct MiniStat: View {
    let value: String
    let label: String
    let symbol: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(NFTheme.accent)
            Text(value)
                .font(.system(size: 23, weight: .black))
                .foregroundStyle(NFTheme.text)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(NFTheme.tertiaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [NFTheme.surfaceRaised, NFTheme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
