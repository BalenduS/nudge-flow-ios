import Foundation

enum AppSyncService {
    @MainActor
    static func sync(model: AppModel, session: SupabaseSession) async throws {
        try await SupabaseClient.shared.upsertProfile(
            SupabaseProfilePayload(
                userId: session.user.id,
                displayName: model.displayName,
                email: session.user.email,
                plan: "free",
                units: model.units.rawValue,
                lastActiveAt: .now
            ),
            session: session
        )

        let consumptionPayloads = model.intakeEntries.map {
            SupabaseConsumptionPayload(
                id: $0.id,
                userId: session.user.id,
                name: $0.name,
                category: $0.category.databaseValue,
                consumedAt: $0.date,
                source: "app"
            )
        }
        try await SupabaseClient.shared.upsertConsumptionEntries(consumptionPayloads, session: session)
    }
}

private extension ConsumptionCategory {
    var databaseValue: String {
        switch self {
        case .meal: "meal"
        case .snack: "snack"
        case .water: "water"
        case .drink: "drink"
        case .caffeine: "caffeine"
        }
    }
}
