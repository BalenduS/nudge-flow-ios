import AppIntents
import SwiftUI
import WidgetKit

struct NudgeFlowWidgetEntry: TimelineEntry {
    let date: Date
    let records: [SharedConsumptionRecord]

    func count(for category: ConsumptionCategory) -> Int {
        records.filter { Calendar.current.isDateInToday($0.date) && $0.category == category }.count
    }
}

struct NudgeFlowWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> NudgeFlowWidgetEntry {
        NudgeFlowWidgetEntry(date: .now, records: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (NudgeFlowWidgetEntry) -> Void) {
        completion(NudgeFlowWidgetEntry(date: .now, records: SharedConsumptionStore.loadRecords()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NudgeFlowWidgetEntry>) -> Void) {
        let entry = NudgeFlowWidgetEntry(date: .now, records: SharedConsumptionStore.loadRecords())
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(15 * 60))))
    }
}

struct NudgeFlowQuickLogWidget: Widget {
    let kind = "NudgeFlowQuickLogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NudgeFlowWidgetProvider()) { entry in
            NudgeFlowWidgetView(entry: entry)
        }
        .configurationDisplayName("Nudge & Flow Log")
        .description("Log water, drinks, snacks, and meals without opening the app.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct NudgeFlowWidgetView: View {
    let entry: NudgeFlowWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Quick log")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text("\(entry.records.filter { Calendar.current.isDateInToday($0.date) }.count)")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(Color.amberAccent)
            }

            HStack(spacing: 8) {
                WidgetLogButton(title: "Water", symbol: "drop.fill", category: .water)
                WidgetLogButton(title: "Coffee", symbol: "mug.fill", category: .caffeine)
            }

            HStack(spacing: 8) {
                WidgetLogButton(title: "Snack", symbol: "takeoutbag.and.cup.and.straw", category: .snack)
                WidgetLogButton(title: "Meal", symbol: "fork.knife", category: .meal)
            }

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                CategoryCount(symbol: "drop.fill", count: entry.count(for: .water))
                CategoryCount(symbol: "mug.fill", count: entry.count(for: .caffeine))
                CategoryCount(symbol: "fork.knife", count: entry.count(for: .meal))
            }
        }
        .containerBackground(Color(red: 0.043, green: 0.039, blue: 0.063), for: .widget)
        .foregroundStyle(Color(red: 0.961, green: 0.953, blue: 0.973))
    }
}

private struct WidgetLogButton: View {
    let title: String
    let symbol: String
    let category: ConsumptionCategory

    var body: some View {
        Button(intent: LogConsumptionIntent(category: category)) {
            Label(title, systemImage: symbol)
                .font(.system(size: 12, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.11))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct CategoryCount: View {
    let symbol: String
    let count: Int

    var body: some View {
        Label("\(count)", systemImage: symbol)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
    }
}

struct LogConsumptionIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Consumption"
    static let description = IntentDescription("Log a common food or drink without opening Nudge & Flow.")
    static let openAppWhenRun = false

    @Parameter(title: "Category")
    var category: ConsumptionCategory

    init() {
        category = .water
    }

    init(category: ConsumptionCategory) {
        self.category = category
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        SharedConsumptionStore.add(name: category.defaultItemName, category: category)
        WidgetCenter.shared.reloadAllTimelines()
        return .result(dialog: "Logged \(category.defaultItemName).")
    }
}

struct NudgeFlowShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogConsumptionIntent(category: .water),
            phrases: ["Log water in \(.applicationName)"],
            shortTitle: "Log Water",
            systemImageName: "drop.fill"
        )

        AppShortcut(
            intent: LogConsumptionIntent(category: .caffeine),
            phrases: ["Log coffee in \(.applicationName)"],
            shortTitle: "Log Coffee",
            systemImageName: "mug.fill"
        )
    }
}

@main
struct NudgeFlowWidgetBundle: WidgetBundle {
    var body: some Widget {
        NudgeFlowQuickLogWidget()
    }
}

private extension Color {
    static let amberAccent = Color(red: 0.9092, green: 0.6349, blue: 0.0)
}
