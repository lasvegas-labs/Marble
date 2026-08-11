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
}
