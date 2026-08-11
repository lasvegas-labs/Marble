import Foundation
import SwiftData

enum SetupProfileStep: Int, CaseIterable, Codable {
    case gender
    case ageRange
    case background
    case interests
    case screenTimePermission
    case distractingApps
    case focusWindow
    case orbPersona

    var next: SetupProfileStep? {
        SetupProfileStep(rawValue: rawValue + 1)
    }
}

enum ProfileGender: String, CaseIterable, Codable, Identifiable {
    case male
    case female
    case preferNotToSay

    var id: Self { self }

    var title: String {
        switch self {
        case .male: "Male"
        case .female: "Female"
        case .preferNotToSay: "Prefer Not to Say"
        }
    }
}

enum ProfileAgeRange: String, CaseIterable, Codable, Identifiable {
    case twentyOneToTwentyFive
    case twentySixToThirty
    case thirtyOneToThirtyFive
    case thirtySixToForty
    case overForty
    case preferNotToSay

    var id: Self { self }

    var title: String {
        switch self {
        case .twentyOneToTwentyFive: "21 - 25 years old"
        case .twentySixToThirty: "26 - 30 years old"
        case .thirtyOneToThirtyFive: "31 - 35 years old"
        case .thirtySixToForty: "36 - 40 years old"
        case .overForty: "More than 40 years old"
        case .preferNotToSay: "Prefer Not to Say"
        }
    }
}

enum ProfileBackground: String, CaseIterable, Codable, Identifiable {
    case student
    case worker
    case other
    case preferNotToSay

    var id: Self { self }

    var title: String {
        switch self {
        case .student: "Student"
        case .worker: "Worker"
        case .other: "Others"
        case .preferNotToSay: "Prefer Not to Say"
        }
    }
}

enum ProfileInterest: String, CaseIterable, Codable, Identifiable {
    case artAndCreativity
    case selfImprovement
    case socialConnection
    case exerciseAndHealth
    case cooking

    var id: Self { self }

    var title: String {
        switch self {
        case .artAndCreativity: "Art & Creativity"
        case .selfImprovement: "Self-Improvement"
        case .socialConnection: "Social Connection"
        case .exerciseAndHealth: "Exercise & Health"
        case .cooking: "Cook"
        }
    }

    var systemImage: String {
        switch self {
        case .artAndCreativity: "theatermasks"
        case .selfImprovement: "brain.head.profile"
        case .socialConnection: "person.2"
        case .exerciseAndHealth: "figure.run"
        case .cooking: "fork.knife"
        }
    }
}

enum ScreenTimePermissionStatus: String, Codable {
    case notDetermined
    case denied
    case approved
    case approvedWithDataAccess
    case failed

    var isApproved: Bool {
        self == .approved || self == .approvedWithDataAccess
    }
}

enum FocusWeekday: Int, CaseIterable, Codable, Identifiable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday

    var id: Self { self }

    var shortTitle: String {
        switch self {
        case .sunday, .saturday: "S"
        case .monday: "M"
        case .tuesday, .thursday: "T"
        case .wednesday: "W"
        case .friday: "F"
        }
    }

    var title: String {
        switch self {
        case .sunday: "Sun"
        case .monday: "Mon"
        case .tuesday: "Tue"
        case .wednesday: "Wed"
        case .thursday: "Thu"
        case .friday: "Fri"
        case .saturday: "Sat"
        }
    }

    var next: FocusWeekday {
        FocusWeekday(rawValue: rawValue % 7 + 1) ?? .sunday
    }
}

enum OrbPersona: String, CaseIterable, Codable, Identifiable {
    case gentle
    case passiveAggressive
    case blunt

    var id: Self { self }

    var title: String {
        switch self {
        case .gentle: "Gentle"
        case .passiveAggressive: "Passive Aggressive"
        case .blunt: "Blunt"
        }
    }

    var index: Double {
        switch self {
        case .gentle: 0
        case .passiveAggressive: 1
        case .blunt: 2
        }
    }

    init(index: Double) {
        switch Int(index.rounded()) {
        case 0: self = .gentle
        case 1: self = .passiveAggressive
        default: self = .blunt
        }
    }
}

@Model
final class SetupProfileModel {
    var id: UUID
    var genderRawValue: String?
    var ageRangeRawValue: String?
    var backgroundRawValue: String?
    var customBackground: String
    var interestRawValues: [String]
    var customInterest: String
    var screenTimePermissionRawValue: String
    var focusStartMinutes: Int?
    var focusEndMinutes: Int?
    var focusWeekdays: [Int]
    var orbPersonaRawValue: String?
    var currentStepRawValue: Int
    var isComplete: Bool
    var isScreenTimeConfigured: Bool
    var updatedAt: Date

    init(id: UUID = UUID()) {
        self.id = id
        genderRawValue = nil
        ageRangeRawValue = nil
        backgroundRawValue = nil
        customBackground = ""
        interestRawValues = []
        customInterest = ""
        screenTimePermissionRawValue = ScreenTimePermissionStatus.notDetermined.rawValue
        focusStartMinutes = nil
        focusEndMinutes = nil
        focusWeekdays = []
        orbPersonaRawValue = nil
        currentStepRawValue = SetupProfileStep.gender.rawValue
        isComplete = false
        isScreenTimeConfigured = false
        updatedAt = .now
    }
}

struct SetupProfilePayload: Encodable, Sendable {
    let gender: String?
    let ageRange: String?
    let background: String?
    let customBackground: String?
    let interests: [String]
    let customInterest: String?
    let screenTimePermissionStatus: String
    let hasSelectedDistractions: Bool
    let focusWindow: FocusWindowPayload?
    let orbPersona: String?
}

struct FocusWindowPayload: Encodable, Sendable {
    let startMinutes: Int
    let endMinutes: Int
    let weekdays: [Int]
    let crossesMidnight: Bool
}
