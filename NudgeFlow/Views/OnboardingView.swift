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
        VStack {
            Spacer()
            VStack(spacing: 22) {
                AppMark()
                Text("Nudge & Flow")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(NFTheme.text)
                Text("Your calm, focused companion for intermittent fasting. Track your window, your progress, your way.")
                    .font(.system(size: 17))
                    .lineSpacing(5)
                    .foregroundStyle(NFTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 290)
            }
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
                GradientButton(title: "Allow Notifications") { model.showPaywall() }
                Button("Not now") { model.showPaywall() }
                    .font(.system(size: 15))
                    .foregroundStyle(NFTheme.tertiaryText)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

struct PaywallView: View {
    @Bindable var model: AppModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if model.openedPaywallFromProfile {
                    Button {
                        model.closePaywall()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(NFTheme.secondaryText)
                            .frame(width: 32, height: 32)
                            .background(.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            ScrollView {
                VStack(spacing: 18) {
                    Text("Unlock Premium")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(NFTheme.text)
                    Text("7 days free, cancel anytime")
                        .font(.system(size: 14))
                        .foregroundStyle(NFTheme.secondaryText)

                    VStack(spacing: 14) {
                        PremiumBullet("Custom fasting plans that adapt to you")
                        PremiumBullet("Detailed weight & fasting analytics")
                        PremiumBullet("Full article library & recipes")
                        PremiumBullet("No ads, ever")
                    }
                    .padding(.vertical, 8)

                    HStack(spacing: 12) {
                        PriceCard(title: "Monthly", price: "$9.99", highlighted: false)
                        PriceCard(title: "Yearly", price: "$49.99", highlighted: true)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
            }

            GradientButton(title: "Start Free Trial") {
                model.closePaywall()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
}

private struct PremiumBullet: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(NFTheme.accent).frame(width: 20, height: 20)
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(NFTheme.text.opacity(0.85))
            Spacer()
        }
    }
}

private struct PriceCard: View {
    let title: String
    let price: String
    let highlighted: Bool

    var body: some View {
        VStack(spacing: 6) {
            if highlighted {
                Text("BEST VALUE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(NFTheme.accentTwo)
                    .clipShape(Capsule())
                    .offset(y: -10)
            }
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(NFTheme.secondaryText)
            Text(price)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(NFTheme.text)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 112)
        .background(highlighted ? NFTheme.surfaceRaised : NFTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(highlighted ? NFTheme.accent : .clear, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
