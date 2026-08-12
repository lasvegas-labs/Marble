import Combine
import Foundation
import SwiftData
import SwiftUI

final class FutureViewModel: ObservableObject {
    static let orbPersonalityKey = "orbPersonality"
    
    @Published var orbPersonality: OrbPersonality = .defaultValue
    @Published private(set) var impactData: FutureImpactResponse?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service = FutureImpactService()

    init() {
        loadOrbPersonality()
    }

    func loadOrbPersonality() {
        let savedValue = UserDefaults.standard.string(forKey: Self.orbPersonalityKey) ?? ""
        self.orbPersonality = OrbPersonality(rawValue: savedValue) ?? .defaultValue
    }

    @MainActor
    func loadImpactData(modelContext: ModelContext) async {
        guard impactData == nil else { return }
        isLoading = true
        errorMessage = nil

        var descriptor = FetchDescriptor<SetupProfileModel>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        let profile = try? modelContext.fetch(descriptor).first

        let role = profile?.backgroundRawValue ?? "entry_level"
        let age = mapAgeRange(profile?.ageRangeRawValue)

        // TODO: Replace with real screen time values when available
        let screenTimeLastWeek = 8
        let screenTimeThisWeek = 6

        let request = FutureImpactRequest(
            screenTimeLastWeek: screenTimeLastWeek,
            screenTimeThisWeek: screenTimeThisWeek,
            age: age,
            role: role
        )

        do {
            let response = try await service.fetchFutureImpact(request: request)
            self.impactData = response
        } catch {
            self.errorMessage = error.localizedDescription
            print("FutureImpact Error:", error.localizedDescription)
            
            // Fallback mock data in case of error
            self.impactData = FutureImpactResponse(
                deltaHoursPerWeek: 2,
                projectionYears: 3,
                totalHours: 312,
                totalDays: 13,
                categories: [
                    FutureImpactCategory(category: "health", message: "Error loading data. Fallback message for health.", iconSFSymbol: "eye.fill"),
                    FutureImpactCategory(category: "productivity", message: "Error loading data. Fallback message for productivity.", iconSFSymbol: "target"),
                    FutureImpactCategory(category: "knowledge", message: "Error loading data. Fallback message for knowledge.", iconSFSymbol: "graduationcap.fill")
                ]
            )
        }
        isLoading = false
    }

    private func mapAgeRange(_ value: String?) -> String {
        switch value {
        case "below15": return "Under 15"
        case "15to20": return "15-20"
        case "21to25": return "21-25"
        case "26to35": return "26-35"
        case "above35": return "36+"
        default: return "21-25"
        }
    }

    var personaColor: Color {
        switch orbPersonality {
        case .gentle:
            return Color(red: 0.0, green: 0.85, blue: 0.60)
        case .passive:
            return Color(red: 1.0, green: 0.75, blue: 0.0)
        case .aggressive:
            return Color(red: 1.0, green: 0.25, blue: 0.25)
        }
    }
}
