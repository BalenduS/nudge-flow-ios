import Foundation
import Observation

@Observable
@MainActor
final class AppModel {
    var screen: AppScreen = .quiz
    var onboardingStep = 0
    var name = ""
    var goal: Goal = .lose
    var gender: Gender = .female
    var ageRange: AgeRange = .twentyFiveToThirtyFour
    var heightCm = 170
    var weightKg = 78.0
    var activity: ActivityLevel = .light
    var experience: Experience = .beginner
    var selectedPlan: FastingPlan = .sixteenEight
    var openedPlansFromProfile = false
    var openedPaywallFromProfile = false
    var activeTab: AppTab = .home
    var units: UnitSystem = .metric
    var fasting = FastingSession()
    var water = 4
    var weightLog = [78.4, 78.1, 77.9, 77.6, 77.2, 77.0, 78.0]
    var mood: Mood?

    var displayName: String { name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Alex" : name }
    var avatarInitial: String { String(displayName.prefix(1)).uppercased() }
    var recommendedPlan: FastingPlan { FastingPlan.recommended(for: experience) }
    var planHours: Double { Double(selectedPlan.fastHours) }

    func continueOnboarding() {
        if onboardingStep >= 7 {
            screen = .analyzing
        } else {
            onboardingStep += 1
        }
    }

    func goBackOnboarding() {
        onboardingStep = max(0, onboardingStep - 1)
    }

    func showPlanSelection(fromProfile: Bool = false) {
        openedPlansFromProfile = fromProfile
        if !fromProfile {
            selectedPlan = recommendedPlan
        }
        screen = .plans
    }

    func confirmPlan() {
        if openedPlansFromProfile {
            activeTab = .profile
            screen = .app
        } else {
            screen = .notifications
        }
    }

    func showPaywall(fromProfile: Bool = false) {
        openedPaywallFromProfile = fromProfile
        screen = .paywall
    }

    func closePaywall() {
        activeTab = openedPaywallFromProfile ? .profile : .home
        screen = .app
    }

    func startFast(now: Date = .now) {
        fasting = FastingSession(active: true, startedAt: now, planHours: selectedPlan.fastHours)
    }

    func endFast() {
        fasting.active = false
    }

    func adjustWater(by delta: Int) {
        water = min(12, max(0, water + delta))
    }

    func adjustWeight(by deltaKg: Double) {
        weightKg = roundedWeight(weightKg + deltaKg)
        if let last = weightLog.indices.last {
            weightLog[last] = roundedWeight(weightLog[last] + deltaKg)
        }
    }

    func toggleUnits() {
        units = units == .metric ? .imperial : .metric
    }

    func displayWeight(_ kilograms: Double? = nil) -> Double {
        let value = kilograms ?? weightKg
        return units == .metric ? value : value * 2.20462
    }

    private func roundedWeight(_ value: Double) -> Double {
        (value * 10).rounded() / 10
    }
}

enum AppScreen {
    case quiz
    case analyzing
    case planRecommendation
    case plans
    case notifications
    case paywall
    case app
}

enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case progress = "Progress"
    case track = "Track"
    case learn = "Learn"
    case profile = "Profile"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .home: "timer"
        case .progress: "chart.bar.fill"
        case .track: "plus.circle"
        case .learn: "book"
        case .profile: "person"
        }
    }
}

enum Goal: String, CaseIterable, Identifiable {
    case lose = "Lose weight"
    case maintain = "Maintain weight"
    case habit = "Build a healthy habit"
    case focus = "Improve mental clarity"
    var id: String { rawValue }
}

enum Gender: String, CaseIterable, Identifiable {
    case female = "Female"
    case male = "Male"
    case other = "Other"
    var id: String { rawValue }
}

enum AgeRange: String, CaseIterable, Identifiable {
    case eighteenToTwentyFour = "18-24"
    case twentyFiveToThirtyFour = "25-34"
    case thirtyFiveToFortyFour = "35-44"
    case fortyFiveToFiftyFour = "45-54"
    case fiftyFivePlus = "55+"
    var id: String { rawValue }
}

enum ActivityLevel: String, CaseIterable, Identifiable {
    case sedentary = "Sedentary"
    case light = "Lightly active"
    case moderate = "Moderately active"
    case active = "Very active"
    var id: String { rawValue }
}

enum Experience: String, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .beginner: "New to fasting"
        case .intermediate: "Fasted before"
        case .advanced: "Fast regularly"
        }
    }
}

enum FastingPlan: String, CaseIterable, Identifiable {
    case sixteenEight = "16:8"
    case eighteenSix = "18:6"
    case twentyFour = "20:4"
    case omad = "OMAD"

    var id: String { rawValue }

    var fastHours: Int {
        switch self {
        case .sixteenEight: 16
        case .eighteenSix: 18
        case .twentyFour: 20
        case .omad: 23
        }
    }

    var subtitle: String {
        switch self {
        case .sixteenEight: "Fast 16h, eat within 8h"
        case .eighteenSix: "Fast 18h, eat within 6h"
        case .twentyFour: "Fast 20h, eat within 4h"
        case .omad: "One meal a day"
        }
    }

    var detail: String {
        switch self {
        case .sixteenEight: "Great for beginners building a routine."
        case .eighteenSix: "A step up with a steadier fat-burning window."
        case .twentyFour: "A single meal window for experienced fasters."
        case .omad: "Maximum simplicity, maximum discipline."
        }
    }

    static func recommended(for experience: Experience) -> FastingPlan {
        switch experience {
        case .beginner: .sixteenEight
        case .intermediate: .eighteenSix
        case .advanced: .twentyFour
        }
    }
}

enum UnitSystem: String {
    case metric
    case imperial

    var weightLabel: String { self == .metric ? "kg" : "lb" }
}

struct FastingSession {
    var active = false
    var startedAt: Date?
    var planHours = 16
}

enum Mood: String, CaseIterable, Identifiable {
    case great = "Great"
    case good = "Good"
    case okay = "Okay"
    case low = "Low"
    case bad = "Bad"
    var id: String { rawValue }
}
