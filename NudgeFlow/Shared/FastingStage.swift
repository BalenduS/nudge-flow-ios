import Foundation

struct FastingStage: Identifiable, Hashable {
    let id: Int
    let hours: Double
    let label: String
    let encouragement: String

    static let all = [
        FastingStage(id: 0, hours: 0, label: "Fed State", encouragement: "You have started. Keep it easy and steady."),
        FastingStage(id: 1, hours: 4, label: "Fat Burning", encouragement: "Nice progress. Your body is shifting gears."),
        FastingStage(id: 2, hours: 12, label: "Ketosis", encouragement: "You are deep into the fast now. Stay hydrated and keep going."),
        FastingStage(id: 3, hours: 16, label: "Fat Loss", encouragement: "Strong work. You have reached a key fasting milestone."),
        FastingStage(id: 4, hours: 24, label: "Autophagy", encouragement: "A serious milestone. Listen to your body and finish with care.")
    ]

    static func current(for elapsedHours: Double) -> FastingStage {
        all.last { elapsedHours >= $0.hours } ?? all[0]
    }
}
