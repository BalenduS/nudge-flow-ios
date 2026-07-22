import Foundation

enum SharedConsumptionStore {
    static let appGroupIdentifier = "group.com.balendu.NudgeFlow"
    private static let entriesKey = "consumption.entries"

    static func loadRecords() -> [SharedConsumptionRecord] {
        guard let data = defaults.data(forKey: entriesKey),
              let records = try? JSONDecoder().decode([SharedConsumptionRecord].self, from: data) else {
            return []
        }
        return records.sorted { $0.date > $1.date }
    }

    static func saveRecords(_ records: [SharedConsumptionRecord]) {
        guard let data = try? JSONEncoder().encode(records.sorted(by: { $0.date > $1.date })) else { return }
        defaults.set(data, forKey: entriesKey)
    }

    static func add(name: String, category: ConsumptionCategory, at date: Date = .now) {
        var records = loadRecords()
        records.insert(SharedConsumptionRecord(name: name, category: category, date: date), at: 0)
        saveRecords(records)
    }

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }
}

struct SharedConsumptionRecord: Codable, Hashable {
    var id: UUID
    var name: String
    var category: ConsumptionCategory
    var date: Date

    init(id: UUID = UUID(), name: String, category: ConsumptionCategory, date: Date) {
        self.id = id
        self.name = name
        self.category = category
        self.date = date
    }
}
