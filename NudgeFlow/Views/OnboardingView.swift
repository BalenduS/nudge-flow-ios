import SwiftUI

struct OnboardingView: View {
    @Bindable var model: AppModel

    var body: some View {
        if model.onboardingStep == 0 {
            WelcomeView(model: model)
        } else {
            QuizStepView(model: model)
        }
    }
}

private struct WelcomeView: View {
    @Bindable var model: AppModel

    var body: some View {
        ZStack {
            RadialGradient(colors: [NFTheme.accent.opacity(0.34), .clear], center: .topTrailing, startRadius: 20, endRadius: 360)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 30)

                VStack(spacing: 28) {
                    ZStack {
                        Circle()
                            .stroke(NFTheme.accent.opacity(0.18), lineWidth: 22)
                            .frame(width: 230, height: 230)
                        Circle()
                            .trim(from: 0.05, to: 0.74)
                            .stroke(NFTheme.gradient, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                            .frame(width: 230, height: 230)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 12) {
                            AppMark(size: 76)
                            Text("16:8")
                                .font(.system(size: 40, weight: .black))
                                .foregroundStyle(NFTheme.text)
                            Text("Today’s flow")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(NFTheme.accentTwo)
                        }
                    }

                    VStack(spacing: 12) {
                        Text("Nudge & Flow")
                            .font(.system(size: 36, weight: .black))
                            .foregroundStyle(NFTheme.text)
                        Text("Fast with momentum, log without stress, and learn what your body responds to.")
                            .font(.system(size: 17, weight: .medium))
                            .lineSpacing(5)
                            .foregroundStyle(NFTheme.secondaryText)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 320)
                    }

                    HStack(spacing: 10) {
                        WelcomePill(symbol: "bell.badge.fill", title: "Stage nudges")
                        WelcomePill(symbol: "plus.circle.fill", title: "Quick logs")
                        WelcomePill(symbol: "chart.line.uptrend.xyaxis", title: "Patterns")
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 12) {
                    GradientButton(title: "Get Started") {
                        model.continueOnboarding()
                    }
                    Text("I already have an account")
                        .font(.system(size: 14))
                        .foregroundStyle(NFTheme.tertiaryText)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

private struct WelcomePill: View {
    let symbol: String
    let title: String

    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(NFTheme.accent)
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(NFTheme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(NFTheme.surface.opacity(0.84))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct QuizStepView: View {
    @Bindable var model: AppModel

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Button {
                    model.goBackOnboarding()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(NFTheme.secondaryText)
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.08))
                        .clipShape(Circle())
                }

                ProgressView(value: Double(model.onboardingStep), total: 7)
                    .tint(NFTheme.accent)
                    .background(.white.opacity(0.08), in: Capsule())
                    .frame(height: 5)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(NFTheme.text)
                    Text(subtitle)
                        .font(.system(size: 15))
                        .foregroundStyle(NFTheme.secondaryText)
                        .padding(.bottom, 14)
                    content
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }

            GradientButton(title: "Continue") {
                model.continueOnboarding()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }

    private var title: String {
        switch model.onboardingStep {
        case 1: "What should we call you?"
        case 2: "What is your main goal?"
        case 3: "What is your gender?"
        case 4: "How old are you?"
        case 5: "Your body stats"
        case 6: "Activity level"
        default: "Fasting experience"
        }
    }

    private var subtitle: String {
        switch model.onboardingStep {
        case 1: "We will use this to personalize your experience."
        case 2: "This helps us personalize your plan."
        case 3: "Used to estimate your fasting metabolism."
        case 4: "Fasting recommendations vary by age group."
        case 5: "We will use this to tailor your targets."
        case 6: "How active are you day-to-day?"
        default: "We will recommend a plan that fits."
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.onboardingStep {
        case 1:
            TextField("Your first name", text: $model.name)
                .textInputAutocapitalization(.words)
                .font(.system(size: 17))
                .foregroundStyle(NFTheme.text)
                .padding(18)
                .background(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.12), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        case 2:
            ForEach(Goal.allCases) { option in
                SelectRow(title: option.rawValue, selected: model.goal == option) { model.goal = option }
            }
        case 3:
            ForEach(Gender.allCases) { option in
                SelectRow(title: option.rawValue, selected: model.gender == option) { model.gender = option }
            }
        case 4:
            ForEach(AgeRange.allCases) { option in
                SelectRow(title: option.rawValue, selected: model.ageRange == option) { model.ageRange = option }
            }
        case 5:
            Card(padding: 22) {
                VStack(spacing: 20) {
                    StepperRow(title: "Height", value: "\(model.heightCm) cm") {
                        model.heightCm = max(140, model.heightCm - 1)
                    } increment: {
                        model.heightCm = min(220, model.heightCm + 1)
                    }
                    Divider().background(.white.opacity(0.08))
                    StepperRow(title: "Weight", value: "\(model.displayWeight().oneDecimal) \(model.units.weightLabel)") {
                        model.adjustWeight(by: -0.5)
                    } increment: {
                        model.adjustWeight(by: 0.5)
                    }
                }
            }
        case 6:
            ForEach(ActivityLevel.allCases) { option in
                SelectRow(title: option.rawValue, selected: model.activity == option) { model.activity = option }
            }
        default:
            ForEach(Experience.allCases) { option in
                SelectRow(title: option.rawValue, subtitle: option.subtitle, selected: model.experience == option) {
                    model.experience = option
                    model.selectedPlan = FastingPlan.recommended(for: option)
                }
            }
        }
    }
}

struct AnalyzingView: View {
    @Bindable var model: AppModel
    @State private var spinning = false

    var body: some View {
        VStack(spacing: 24) {
            Circle()
                .trim(from: 0.08, to: 0.78)
                .stroke(NFTheme.gradient, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(spinning ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: spinning)
            Text("Building your fasting plan...")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(NFTheme.text)
        }
        .task {
            spinning = true
            try? await Task.sleep(for: .seconds(1.6))
            model.screen = .planRecommendation
        }
    }
}

struct PlanRecommendationView: View {
    @Bindable var model: AppModel

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 18) {
                Text("Recommended for you")
                    .font(.system(size: 13, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(NFTheme.accentTwo)
                Text(model.recommendedPlan.rawValue)
                    .font(.system(size: 52, weight: .black))
                    .foregroundStyle(NFTheme.text)
                Text(model.recommendedPlan.subtitle)
                    .font(.system(size: 16))
                    .foregroundStyle(NFTheme.secondaryText)
                Card(padding: 20) {
                    Text(model.recommendedPlan.detail)
                        .font(.system(size: 15))
                        .lineSpacing(5)
                        .foregroundStyle(NFTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 28)
            Spacer()
            GradientButton(title: "Choose My Plan") {
                model.showPlanSelection()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

struct PlanSelectionView: View {
    @Bindable var model: AppModel

    var body: some View {
        VStack(spacing: 0) {
            Text("Choose your plan")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(NFTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 14) {
                    ForEach(FastingPlan.allCases) { plan in
                        SelectRow(title: plan.rawValue, subtitle: "\(plan.subtitle)\n\(plan.detail)", selected: model.selectedPlan == plan) {
                            model.selectedPlan = plan
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            GradientButton(title: "Continue") {
                model.confirmPlan()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
}

struct NotificationsView: View {
    @Bindable var model: AppModel

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(NFTheme.accent)
                    .frame(width: 76, height: 76)
                    .background(NFTheme.accent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                Text("Stay on track")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(NFTheme.text)
                Text("Get a gentle nudge when your fasting window opens, and celebrate milestones along the way.")
                    .font(.system(size: 15))
                    .lineSpacing(4)
                    .foregroundStyle(NFTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }
            Spacer()
            VStack(spacing: 12) {
                GradientButton(title: "Allow Notifications") {
                    Task {
                        await FastingNotificationScheduler.requestAuthorization()
                        model.completeOnboarding()
                    }
                }
                Button("Not now") { model.completeOnboarding() }
                    .font(.system(size: 15))
                    .foregroundStyle(NFTheme.tertiaryText)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
