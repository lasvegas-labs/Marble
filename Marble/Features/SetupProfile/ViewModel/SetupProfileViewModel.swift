import Combine
import FamilyControls
import Foundation
import SwiftData

@MainActor
final class SetupProfileViewModel: ObservableObject {
    @Published private(set) var currentStep: SetupProfileStep
    @Published var gender: ProfileGender?
    @Published var ageRange: ProfileAgeRange?
    @Published var background: ProfileBackground?
    @Published var customBackground: String
    @Published var selectedInterests: Set<ProfileInterest>
    @Published var customInterest: String
    @Published private(set) var permissionStatus: ScreenTimePermissionStatus
    @Published var activitySelection: FamilyActivitySelection
    @Published var focusStartTime: Date
    @Published var focusEndTime: Date
    @Published var selectedWeekdays: Set<FocusWeekday>
    @Published var orbPersonality: OrbPersonality
    @Published var isActivityPickerPresented = false
    @Published private(set) var isWorking = false
    @Published var errorMessage: String?

    private let modelContext: ModelContext
    private let screenTimeService: ScreenTimeService
    private let model: SetupProfileModel

    init(
        modelContext: ModelContext,
        screenTimeService: ScreenTimeService
    ) {
        self.modelContext = modelContext
        self.screenTimeService = screenTimeService

        var descriptor = FetchDescriptor<SetupProfileModel>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1

        if let existing = try? modelContext.fetch(descriptor).first {
            model = existing
        } else {
            let newModel = SetupProfileModel()
            modelContext.insert(newModel)
            model = newModel
        }

        currentStep = SetupProfileStep(
            rawValue: model.currentStepRawValue
        ) ?? .gender
        gender = model.genderRawValue.flatMap(ProfileGender.init(rawValue:))
        ageRange = model.ageRangeRawValue.flatMap(ProfileAgeRange.init(rawValue:))
        background = model.backgroundRawValue.flatMap(ProfileBackground.init(rawValue:))
        customBackground = model.customBackground
        selectedInterests = Set(
            model.interestRawValues.compactMap(ProfileInterest.init(rawValue:))
        )
        customInterest = model.customInterest
        permissionStatus = ScreenTimePermissionStatus(
            rawValue: model.screenTimePermissionRawValue
        ) ?? screenTimeService.authorizationStatus
        activitySelection = screenTimeService.loadSelection()

        let defaultStartMinutes = 9 * 60
        let defaultEndMinutes = 17 * 60
        focusStartTime = Self.date(
            minutesFromMidnight: model.focusStartMinutes ?? defaultStartMinutes
        )
        focusEndTime = Self.date(
            minutesFromMidnight: model.focusEndMinutes ?? defaultEndMinutes
        )

        if model.currentStepRawValue >= SetupProfileStep.focusWindow.rawValue {
            selectedWeekdays = Set(
                model.focusWeekdays.compactMap(FocusWeekday.init(rawValue:))
            )
        } else {
            selectedWeekdays = [.monday, .tuesday, .wednesday, .thursday, .friday]
        }

        orbPersonality = model.orbPersonaRawValue
            .flatMap(OrbPersonality.init(rawValue:)) ?? .defaultValue
    }

    var stepNumber: Int { currentStep.rawValue + 1 }
    var stepCount: Int { SetupProfileStep.allCases.count }

    var selectedDistractionCount: Int {
        activitySelection.applicationTokens.count
            + activitySelection.categoryTokens.count
            + activitySelection.webDomainTokens.count
    }

    var crossesMidnight: Bool {
        focusEndMinutes < focusStartMinutes
    }

    var payload: SetupProfilePayload {
        let focusWindow: FocusWindowPayload?
        if
            let startMinutes = model.focusStartMinutes,
            let endMinutes = model.focusEndMinutes,
            !model.focusWeekdays.isEmpty,
            startMinutes != endMinutes
        {
            focusWindow = FocusWindowPayload(
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                weekdays: model.focusWeekdays.sorted(),
                crossesMidnight: endMinutes < startMinutes
            )
        } else {
            focusWindow = nil
        }

        return SetupProfilePayload(
            gender: model.genderRawValue,
            ageRange: model.ageRangeRawValue,
            background: model.backgroundRawValue,
            customBackground: model.customBackground.nilIfBlank,
            interests: model.interestRawValues,
            customInterest: model.customInterest.nilIfBlank,
            screenTimePermissionStatus: model.screenTimePermissionRawValue,
            hasSelectedDistractions: selectedDistractionCount > 0,
            focusWindow: focusWindow,
            orbPersona: model.orbPersonaRawValue
        )
    }

    func continueCurrentStep() async -> Bool {
        guard !isWorking else { return false }
        isWorking = true
        defer { isWorking = false }

        switch currentStep {
        case .screenTimePermission:
            permissionStatus = await screenTimeService.requestAuthorization()
            let nextStep: SetupProfileStep = permissionStatus.isApproved
                ? .distractingApps
                : .orbPersona
            return persist(nextStep: nextStep)

        case .distractingApps:
            do {
                try screenTimeService.saveSelection(activitySelection)
            } catch {
                errorMessage = error.localizedDescription
                return false
            }
            return persist(nextStep: .focusWindow)

        case .orbPersona:
            return completeProfile(personaSkipped: false)

        default:
            guard let nextStep = currentStep.next else { return false }
            return persist(nextStep: nextStep)
        }
    }

    func skipCurrentStep() -> Bool {
        switch currentStep {
        case .screenTimePermission:
            permissionStatus = screenTimeService.authorizationStatus
            return persist(nextStep: .orbPersona)

        case .distractingApps:
            activitySelection = FamilyActivitySelection()
            screenTimeService.clearSelection()
            return persist(nextStep: .focusWindow)

        case .focusWindow:
            selectedWeekdays = []
            return persist(nextStep: .orbPersona)

        case .orbPersona:
            return completeProfile(personaSkipped: true)

        default:
            guard let nextStep = currentStep.next else { return false }
            return persist(nextStep: nextStep)
        }
    }

    func goBack() -> Bool {
        guard currentStep != .gender else { return false }

        let previousStep: SetupProfileStep
        if currentStep == .orbPersona, !permissionStatus.isApproved {
            previousStep = .screenTimePermission
        } else {
            previousStep = SetupProfileStep(rawValue: currentStep.rawValue - 1) ?? .gender
        }

        return persist(nextStep: previousStep)
    }

    func toggleInterest(_ interest: ProfileInterest) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }

    func toggleWeekday(_ weekday: FocusWeekday) {
        if selectedWeekdays.contains(weekday) {
            selectedWeekdays.remove(weekday)
        } else {
            selectedWeekdays.insert(weekday)
        }
    }

    private var focusStartMinutes: Int {
        Self.minutesFromMidnight(focusStartTime)
    }

    private var focusEndMinutes: Int {
        Self.minutesFromMidnight(focusEndTime)
    }

    private func persist(nextStep: SetupProfileStep) -> Bool {
        writeCurrentState(personaSkipped: false)
        model.currentStepRawValue = nextStep.rawValue
        model.updatedAt = .now

        do {
            try modelContext.save()
            currentStep = nextStep
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func completeProfile(personaSkipped: Bool) -> Bool {
        writeCurrentState(personaSkipped: personaSkipped)
        model.currentStepRawValue = SetupProfileStep.orbPersona.rawValue
        model.isComplete = true
        model.isScreenTimeConfigured = false
        model.updatedAt = .now

        do {
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
            return false
        }

        guard permissionStatus.isApproved, selectedDistractionCount > 0 else {
            screenTimeService.stopFocusMonitoring()
            return true
        }

        do {
            try screenTimeService.saveSelection(activitySelection)
            model.isScreenTimeConfigured = try screenTimeService.configureFocusMonitoring(
                startMinutes: model.focusStartMinutes,
                endMinutes: model.focusEndMinutes,
                weekdays: Set(
                    model.focusWeekdays.compactMap(FocusWeekday.init(rawValue:))
                )
            )
            try modelContext.save()
        } catch {
            model.isScreenTimeConfigured = false
            try? modelContext.save()
            errorMessage = "Your profile was saved, but the focus schedule could not be activated."
        }

        return true
    }

    private func writeCurrentState(personaSkipped: Bool) {
        model.genderRawValue = gender?.rawValue
        model.ageRangeRawValue = ageRange?.rawValue
        model.backgroundRawValue = background?.rawValue
        model.customBackground = customBackground.trimmingCharacters(in: .whitespacesAndNewlines)
        model.interestRawValues = selectedInterests.map(\.rawValue).sorted()
        model.customInterest = customInterest.trimmingCharacters(in: .whitespacesAndNewlines)
        model.screenTimePermissionRawValue = permissionStatus.rawValue

        if currentStep.rawValue >= SetupProfileStep.focusWindow.rawValue {
            model.focusStartMinutes = selectedWeekdays.isEmpty ? nil : focusStartMinutes
            model.focusEndMinutes = selectedWeekdays.isEmpty ? nil : focusEndMinutes
            model.focusWeekdays = selectedWeekdays.map(\.rawValue).sorted()
        }

        if currentStep == .orbPersona {
            model.orbPersonaRawValue = personaSkipped ? nil : orbPersonality.rawValue
            if !personaSkipped {
                UserDefaults.standard.set(orbPersonality.rawValue, forKey: "orbPersonality")
            }
        }
    }

    private static func date(minutesFromMidnight: Int) -> Date {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        return calendar.date(
            byAdding: .minute,
            value: minutesFromMidnight,
            to: startOfToday
        ) ?? .now
    }

    private static func minutesFromMidnight(_ date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
}

private extension String {
    var nilIfBlank: String? {
        isEmpty ? nil : self
    }
}
