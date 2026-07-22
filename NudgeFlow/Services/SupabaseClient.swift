import Foundation

enum SupabaseError: LocalizedError {
    case notConfigured
    case invalidURL
    case missingSession
    case emptyResponse
    case server(status: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            "Add your Supabase project URL and anon key in SupabaseConfig.swift."
        case .invalidURL:
            "The Supabase URL is not valid."
        case .missingSession:
            "Please sign in before syncing."
        case .emptyResponse:
            "Supabase returned an empty response."
        case let .server(status, message):
            "Supabase error \(status): \(message)"
        }
    }
}

struct SupabaseSession: Codable, Equatable {
    var accessToken: String
    var refreshToken: String?
    var expiresAt: Date?
    var user: SupabaseUser
}

struct SupabaseUser: Codable, Equatable {
    var id: UUID
    var email: String?
}

final class SupabaseClient {
    static let shared = SupabaseClient()

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
    }

    func signUp(email: String, password: String, displayName: String) async throws -> SupabaseSession {
        let response: AuthResponse = try await request(
            path: "/auth/v1/signup",
            method: "POST",
            body: SignUpRequest(email: email, password: password, data: ["display_name": displayName]),
            authenticated: false
        )
        return try response.session()
    }

    func signIn(email: String, password: String) async throws -> SupabaseSession {
        let response: AuthResponse = try await request(
            path: "/auth/v1/token",
            queryItems: [URLQueryItem(name: "grant_type", value: "password")],
            method: "POST",
            body: PasswordRequest(email: email, password: password),
            authenticated: false
        )
        return try response.session()
    }

    func signOut(session: SupabaseSession) async throws {
        try await requestWithoutResponse(
            path: "/auth/v1/logout",
            method: "POST",
            body: EmptyBody(),
            session: session
        )
    }

    func upsertProfile(_ profile: SupabaseProfilePayload, session: SupabaseSession) async throws {
        try await restWithoutResponse(
            table: "profiles",
            queryItems: [URLQueryItem(name: "on_conflict", value: "user_id")],
            method: "POST",
            body: [profile],
            session: session,
            prefer: "resolution=merge-duplicates,return=minimal"
        )
    }

    func upsertConsumptionEntries(_ entries: [SupabaseConsumptionPayload], session: SupabaseSession) async throws {
        guard !entries.isEmpty else { return }
        try await restWithoutResponse(
            table: "consumption_entries",
            queryItems: [URLQueryItem(name: "on_conflict", value: "id")],
            method: "POST",
            body: entries,
            session: session,
            prefer: "resolution=ignore-duplicates,return=minimal"
        )
    }

    private func request<Response: Decodable, Body: Encodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        method: String,
        body: Body,
        authenticated: Bool
    ) async throws -> Response {
        let data = try await dataRequest(path: path, queryItems: queryItems, method: method, body: body, session: nil)
        guard !data.isEmpty else { throw SupabaseError.emptyResponse }
        return try decoder.decode(Response.self, from: data)
    }

    private func requestWithoutResponse<Body: Encodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        method: String,
        body: Body,
        session: SupabaseSession
    ) async throws {
        _ = try await dataRequest(path: path, queryItems: queryItems, method: method, body: body, session: session)
    }

    private func restWithoutResponse<Body: Encodable>(
        table: String,
        queryItems: [URLQueryItem],
        method: String,
        body: Body,
        session: SupabaseSession,
        prefer: String
    ) async throws {
        _ = try await dataRequest(
            path: "/rest/v1/\(table)",
            queryItems: queryItems,
            method: method,
            body: body,
            session: session,
            prefer: prefer
        )
    }

    private func dataRequest<Body: Encodable>(
        path: String,
        queryItems: [URLQueryItem],
        method: String,
        body: Body,
        session: SupabaseSession?,
        prefer: String? = nil
    ) async throws -> Data {
        guard SupabaseConfig.isConfigured else { throw SupabaseError.notConfigured }
        guard let baseURL = SupabaseConfig.projectURL else { throw SupabaseError.invalidURL }
        guard var components = URLComponents(string: baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + path) else {
            throw SupabaseError.invalidURL
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else { throw SupabaseError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let prefer {
            request.setValue(prefer, forHTTPHeaderField: "Prefer")
        }
        if let session {
            request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { return data }
        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw SupabaseError.server(status: httpResponse.statusCode, message: message)
        }
        return data
    }
}

private struct EmptyBody: Encodable {}

private struct SignUpRequest: Encodable {
    var email: String
    var password: String
    var data: [String: String]
}

private struct PasswordRequest: Encodable {
    var email: String
    var password: String
}

private struct AuthResponse: Decodable {
    var accessToken: String?
    var refreshToken: String?
    var expiresIn: TimeInterval?
    var user: SupabaseAuthUser?

    func session() throws -> SupabaseSession {
        guard let accessToken, let userID = user?.id else { throw SupabaseError.emptyResponse }
        let expiresAt = expiresIn.map { Date().addingTimeInterval($0) }
        return SupabaseSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt,
            user: SupabaseUser(id: userID, email: user?.email)
        )
    }
}

private struct SupabaseAuthUser: Decodable {
    var id: UUID
    var email: String?
}

struct SupabaseProfilePayload: Encodable {
    var userId: UUID
    var displayName: String
    var email: String?
    var plan: String
    var units: String
    var lastActiveAt: Date
}

struct SupabaseConsumptionPayload: Encodable {
    var id: UUID
    var userId: UUID
    var name: String
    var category: String
    var consumedAt: Date
    var source: String
}
