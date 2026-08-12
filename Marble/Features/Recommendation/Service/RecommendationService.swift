//
//  RecommendationService.swift
//  Marble
//
//  Created by otnielkalit on 12/08/26.
//

import Foundation

enum RecommendationServiceError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid URL"
        case .networkError(let e): e.localizedDescription
        case .decodingError(let e): e.localizedDescription
        }
    }
}

final class RecommendationService {
    private let endpoint = AppConfig.recommendationEndpoint

    func fetchRecommendations(request: RecommendationRequest) async throws -> [RecommendationItem] {
        guard let url = URL(string: endpoint) else {
            throw RecommendationServiceError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        let encoder = JSONEncoder()
        urlRequest.httpBody = try? encoder.encode(request)

        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let items = try JSONDecoder().decode([RecommendationItem].self, from: data)
            return items
        } catch let error as DecodingError {
            throw RecommendationServiceError.decodingError(error)
        } catch {
            throw RecommendationServiceError.networkError(error)
        }
    }
}
