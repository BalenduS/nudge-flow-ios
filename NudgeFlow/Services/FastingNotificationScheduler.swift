import Foundation
import UserNotifications

enum FastingNotificationScheduler {
    private static let categoryIdentifier = "fasting-stage"

    static func requestAuthorization() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }

    static func scheduleStageNotifications(startedAt: Date, planHours: Int) {
        cancelStageNotifications()

        for stage in FastingStage.all where stage.hours > 0 && stage.hours <= Double(planHours) {
            let fireDate = startedAt.addingTimeInterval(stage.hours * 3600)
            guard fireDate > .now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "\(stage.label) reached"
            content.body = stage.encouragement
            content.sound = .default
            content.categoryIdentifier = categoryIdentifier

            let interval = max(1, fireDate.timeIntervalSinceNow)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: identifier(for: stage), content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }

    static func cancelStageNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: FastingStage.all.map(identifier(for:))
        )
    }

    private static func identifier(for stage: FastingStage) -> String {
        "nudge-flow.stage.\(stage.id)"
    }
}
