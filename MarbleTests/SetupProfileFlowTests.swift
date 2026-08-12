import FamilyControls
import Foundation
import SwiftData
import Testing
@testable import Marble

@MainActor
struct SetupProfileFlowTests {
    @Test
    func draftResumesAndCompletionPersists() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: SetupProfileModel.self,
            configurations: configuration
        )
        let defaultsName = "SetupProfileFlowTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: defaultsName)
        defer { defaults?.removePersistentDomain(forName: defaultsName) }

        let firstSession = SetupProfileViewModel(
            modelContext: container.mainContext,
            screenTimeService: ScreenTimeService(sharedDefaults: defaults)
        )
        #expect(firstSession.skipCurrentStep())
        #expect(firstSession.skipCurrentStep())
        #expect(firstSession.currentStep == .background)

        let resumedSession = SetupProfileViewModel(
            modelContext: container.mainContext,
            screenTimeService: ScreenTimeService(sharedDefaults: defaults)
        )
        #expect(resumedSession.currentStep == .background)

        #expect(resumedSession.skipCurrentStep())
        #expect(resumedSession.skipCurrentStep())
        #expect(resumedSession.skipCurrentStep())
        #expect(resumedSession.currentStep == SetupProfileStep.orbPersona)
        #expect(resumedSession.skipCurrentStep())

        let profiles = try container.mainContext.fetch(
            FetchDescriptor<SetupProfileModel>()
        )
        #expect(profiles.count == 1)
        #expect(profiles.first?.isComplete == true)
    }

    @Test
    func screenTimeSelectionUsesMainStorageContract() throws {
        let defaultsName = "SetupProfileFlowTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: defaultsName))
        defer { defaults.removePersistentDomain(forName: defaultsName) }

        let service = ScreenTimeService(sharedDefaults: defaults)
        let selection = FamilyActivitySelection()

        try service.saveSelection(selection)

        let storedData = try #require(
            defaults.data(forKey: ScreenTimeStorage.selectionKey)
        )
        let decodedSelection = try PropertyListDecoder().decode(
            FamilyActivitySelection.self,
            from: storedData
        )

        #expect(ScreenTimeStorage.selectionKey == "saved_activity_selection")
        #expect(
            defaults.integer(forKey: ScreenTimeStorage.thresholdMinutesKey)
                == ScreenTimeStorage.defaultThresholdMinutes
        )
        #expect(decodedSelection.applicationTokens.isEmpty)
        #expect(decodedSelection.categoryTokens.isEmpty)
        #expect(decodedSelection.webDomainTokens.isEmpty)
        #expect(service.loadSelection().applicationTokens.isEmpty)
    }

    @Test
    func focusScheduleAdvancesWeekdayWhenCrossingMidnight() throws {
        var calendar = Calendar(identifier: .gregorian)
        let timeZone = try #require(TimeZone(secondsFromGMT: 0))
        calendar.timeZone = timeZone

        let schedule = try #require(
            ScreenTimeService.focusSchedule(
                startMinutes: 23 * 60,
                endMinutes: 60,
                weekday: .friday,
                calendar: calendar,
                timeZone: timeZone
            )
        )

        #expect(schedule.intervalStart.weekday == FocusWeekday.friday.rawValue)
        #expect(schedule.intervalStart.hour == 23)
        #expect(schedule.intervalEnd.weekday == FocusWeekday.saturday.rawValue)
        #expect(schedule.intervalEnd.hour == 1)
        #expect(schedule.repeats)
    }

    @Test
    func focusScheduleRejectsEmptyOrOutOfRangeWindows() {
        #expect(
            ScreenTimeService.focusSchedule(
                startMinutes: 9 * 60,
                endMinutes: 9 * 60,
                weekday: .monday
            ) == nil
        )
        #expect(
            ScreenTimeService.focusSchedule(
                startMinutes: -1,
                endMinutes: 10 * 60,
                weekday: .monday
            ) == nil
        )
    }
}
