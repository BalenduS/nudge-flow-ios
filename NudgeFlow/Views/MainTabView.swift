import SwiftUI

struct MainTabView: View {
    @Bindable var model: AppModel
    @Bindable var auth: AuthModel

    var body: some View {
        TabView(selection: $model.activeTab) {
            HomeView(model: model)
                .tabItem { Label(AppTab.home.rawValue, systemImage: AppTab.home.symbol) }
                .tag(AppTab.home)

            FastingProgressView(model: model)
                .tabItem { Label(AppTab.progress.rawValue, systemImage: AppTab.progress.symbol) }
                .tag(AppTab.progress)

            TrackView(model: model, auth: auth)
                .tabItem { Label(AppTab.track.rawValue, systemImage: AppTab.track.symbol) }
                .tag(AppTab.track)

            LearnView()
                .tabItem { Label(AppTab.learn.rawValue, systemImage: AppTab.learn.symbol) }
                .tag(AppTab.learn)

            ProfileView(model: model, auth: auth)
                .tabItem { Label(AppTab.profile.rawValue, systemImage: AppTab.profile.symbol) }
                .tag(AppTab.profile)
        }
        .tint(NFTheme.accent)
        .toolbarBackground(NFTheme.surface.opacity(0.94), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

struct ScreenScroll<Content: View>: View {
    var title: String?
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let title {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(NFTheme.text)
                }
                content
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 18)
        }
        .background(NFTheme.background.ignoresSafeArea())
    }
}
