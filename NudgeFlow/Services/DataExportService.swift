import Foundation

enum DataExportService {
    @MainActor
    static func makeCSVFile(model: AppModel) throws -> URL {
        let csv = makeCSV(model: model)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        let filename = "nudge-flow-export-\(formatter.string(from: .now)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    @MainActor
    private static func makeCSV(model: AppModel) -> String {
        var rows = [["section", "type", "name", "category", "value", "unit", "date"]]

        rows.append(["profile", "name", model.displayName, "", "", "", ""])
        rows.append(["profile", "plan", model.selectedPlan.rawValue, "", "\(model.selectedPlan.fastHours)", "hours", ""])
        rows.append(["profile", "units", model.units.rawValue, "", "", "", ""])
        rows.append(["tracking", "water", "Today", "Water", "\(model.water)", "glasses", isoString(.now)])
        rows.append(["tracking", "weight", "Current Weight", "Weight", model.displayWeight().oneDecimal, model.units.weightLabel, isoString(.now)])

        if let mood = model.mood {
            rows.append(["tracking", "mood", mood.rawValue, "Mood", mood.rawValue, "", isoString(.now)])
        }

        if model.fasting.active, let startedAt = model.fasting.startedAt {
            rows.append(["fasting", "active_start", model.selectedPlan.rawValue, "Fast", "\(model.fasting.planHours)", "hours", isoString(startedAt)])
            rows.append(["fasting", "active_goal", model.selectedPlan.rawValue, "Fast", "\(model.fasting.planHours)", "hours", isoString(startedAt.addingTimeInterval(Double(model.fasting.planHours) * 3600))])
        }

        for (index, weight) in model.weightLog.enumerated() {
            let date = Calendar.current.date(byAdding: .day, value: index - model.weightLog.count + 1, to: .now) ?? .now
            let value = model.displayWeight(weight).oneDecimal
            rows.append(["weight_log", "weight", "Weight", "Weight", value, model.units.weightLabel, isoString(date)])
        }

        for entry in model.intakeEntries.sorted(by: { $0.date > $1.date }) {
            rows.append([
                "consumption",
                "entry",
                entry.name,
                entry.category.rawValue,
                "1",
                "count",
                isoString(entry.date)
            ])
        }

        return rows.map(csvLine).joined(separator: "\n")
    }

    private static func csvLine(_ fields: [String]) -> String {
        fields.map { field in
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            if escaped.contains(",") || escaped.contains("\n") || escaped.contains("\"") {
                return "\"\(escaped)\""
            }
            return escaped
        }
        .joined(separator: ",")
    }

    private static func isoString(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }
}
