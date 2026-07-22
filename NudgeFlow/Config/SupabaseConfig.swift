import Foundation

enum SupabaseConfig {
    static let projectURLString = "https://YOUR-PROJECT-REF.supabase.co"
    static let anonKey = "YOUR-SUPABASE-ANON-KEY"

    static var isConfigured: Bool {
        projectURLString.hasPrefix("https://")
            && !projectURLString.contains("YOUR-PROJECT-REF")
            && !anonKey.contains("YOUR-SUPABASE-ANON-KEY")
    }

    static var projectURL: URL? {
        URL(string: projectURLString)
    }
}
