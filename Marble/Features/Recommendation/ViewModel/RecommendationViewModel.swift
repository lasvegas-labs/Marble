//
//  RecommendationViewModel.swift
//  Marble
//
//  Created by otnielkalit on 12/08/26.
//

import Combine
import SwiftData
import SwiftUI

@MainActor
final class RecommendationViewModel: ObservableObject {
    @Published private(set) var items: [RecommendationItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service = RecommendationService()
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func load() async {
        guard items.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        let profile = fetchLatestProfile()
        let request = buildRequest(from: profile)

        do {
            let result = try await service.fetchRecommendations(request: request)
            items = result.isEmpty ? RecommendationViewModel.fallbackItems : result
        } catch {
            errorMessage = error.localizedDescription
            items = RecommendationViewModel.fallbackItems
        }
        isLoading = false
    }

    private func fetchLatestProfile() -> SetupProfileModel? {
        var descriptor = FetchDescriptor<SetupProfileModel>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }

    private func buildRequest(from profile: SetupProfileModel?) -> RecommendationRequest {
        let role = profile?.backgroundRawValue ?? "other"
        let age = mapAgeRange(profile?.ageRangeRawValue)
        let stylePersonal = profile?.orbPersonaRawValue ?? OrbPersonality.defaultValue.rawValue
        let gender = mapGender(profile?.genderRawValue)
        let hobbies = mapInterests(profile?.interestRawValues ?? [])
        let app = UserDefaults(suiteName: AppConfig.appGroupIdentifier)?
            .string(forKey: AppConfig.lastTriggeredAppKey) ?? "App"
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        let time = formatter.string(from: Date())

        return RecommendationRequest(
            role: role,
            age: age,
            stylePersonal: stylePersonal,
            gender: gender,
            hobby: hobbies,
            app: app,
            time: time
        )
    }

    private func mapAgeRange(_ rawValue: String?) -> String {
        guard let raw = rawValue else { return "21-25" }
        switch raw {
        case "twentyOneToTwentyFive": return "21-25"
        case "twentySixToThirty": return "26-30"
        case "thirtyOneToThirtyFive": return "31-35"
        case "thirtySixToForty": return "36-40"
        case "overForty": return "40+"
        default: return "21-25"
        }
    }

    private func mapGender(_ rawValue: String?) -> String {
        guard let raw = rawValue else { return "prefer not to say" }
        switch raw {
        case "male": return "laki-laki"
        case "female": return "perempuan"
        default: return "prefer not to say"
        }
    }

    private func mapInterests(_ rawValues: [String]) -> [String] {
        rawValues.compactMap { raw -> String? in
            switch raw {
            case "artAndCreativity": return "art"
            case "selfImprovement": return "self improvement"
            case "socialConnection": return "social"
            case "exerciseAndHealth": return "exercise"
            case "cooking": return "cooking"
            default: return nil
            }
        }
    }

    static let fallbackItems: [RecommendationItem] = [
        RecommendationItem(
            message: "Rapikan satu baris kode dulu, daripada mata kamu makin lelah scrolling",
            iconSFSymbol: "star.fill",
            colorName: "green",
            colorStart: "#6EE7B7",
            colorEnd: "#10B981"
        ),
        RecommendationItem(
            message: "Beda banget dengan senandung gitar yang siap kamu petik",
            iconSFSymbol: "music.note",
            colorName: "purple",
            colorStart: "#C4B5FD",
            colorEnd: "#8B5CF6"
        ),
        RecommendationItem(
            message: "Paling pas buat peregangan otot sebentar ketimbang rebahan",
            iconSFSymbol: "figure.run",
            colorName: "blue",
            colorStart: "#93C5FD",
            colorEnd: "#3B82F6"
        )
    ]
}
