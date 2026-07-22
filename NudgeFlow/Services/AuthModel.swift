import Foundation
import Observation

@Observable
@MainActor
final class AuthModel {
    private(set) var session: SupabaseSession?
    private(set) var isWorking = false
    var errorMessage: String?

    var isSignedIn: Bool { session != nil }
    var email: String { session?.user.email ?? "Signed in" }
    var isConfigured: Bool { SupabaseConfig.isConfigured }

    init() {
        session = SessionStore.load()
    }

    func signUp(email: String, password: String, displayName: String, appModel: AppModel) async {
        await perform {
            let session = try await SupabaseClient.shared.signUp(email: email, password: password, displayName: displayName)
            self.setSession(session)
            appModel.name = displayName.isEmpty ? appModel.displayName : displayName
            try await AppSyncService.sync(model: appModel, session: session)
        }
    }

    func signIn(email: String, password: String, appModel: AppModel) async {
        await perform {
            let session = try await SupabaseClient.shared.signIn(email: email, password: password)
            self.setSession(session)
            try await AppSyncService.sync(model: appModel, session: session)
        }
    }

    func sync(appModel: AppModel) async {
        guard let session else {
            errorMessage = SupabaseError.missingSession.localizedDescription
            return
        }
        await perform {
            try await AppSyncService.sync(model: appModel, session: session)
        }
    }

    func signOut() async {
        guard let session else { return }
        await perform {
            try? await SupabaseClient.shared.signOut(session: session)
            self.session = nil
            SessionStore.clear()
        }
    }

    private func perform(_ operation: @escaping () async throws -> Void) async {
        isWorking = true
        errorMessage = nil
        do {
            try await operation()
        } catch {
            errorMessage = error.localizedDescription
        }
        isWorking = false
    }

    private func setSession(_ session: SupabaseSession) {
        self.session = session
        SessionStore.save(session)
    }
}

private enum SessionStore {
    private static let key = "supabase.session"

    static func load() -> SupabaseSession? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(SupabaseSession.self, from: data)
    }

    static func save(_ session: SupabaseSession) {
        guard let data = try? JSONEncoder().encode(session) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
