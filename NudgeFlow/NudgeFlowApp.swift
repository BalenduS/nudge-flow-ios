import SwiftUI

@main
struct NudgeFlowApp: App {
    @State private var model = AppModel()
    @State private var auth = AuthModel()

    var body: some Scene {
        WindowGroup {
            RootView(model: model, auth: auth)
                .preferredColorScheme(.dark)
        }
    }
}

private struct RootView: View {
    @Bindable var model: AppModel
    @Bindable var auth: AuthModel

    var body: some View {
        ZStack {
            NFTheme.background.ignoresSafeArea()

            switch model.screen {
            case .quiz:
                OnboardingView(model: model)
            case .analyzing:
                AnalyzingView(model: model)
            case .planRecommendation:
                PlanRecommendationView(model: model)
            case .plans:
                PlanSelectionView(model: model)
            case .notifications:
                NotificationsView(model: model)
            case .app:
                MainTabView(model: model, auth: auth)
            }
        }
    }
}
