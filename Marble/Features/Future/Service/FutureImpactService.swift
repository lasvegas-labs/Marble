//
//  FutureImpactService.swift
//  Marble
//
//  Created by otnielkalit on 12/08/26.
//

import Foundation

enum FutureImpactServiceError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .networkError(let e): return e.localizedDescription
        case .decodingError(let e): return e.localizedDescription
        }
    }
}

final class FutureImpactService {
    private let endpoint = AppConfig.futureImpactEndpoint

    func fetchFutureImpact(request: FutureImpactRequest) async throws -> FutureImpactResponse {
        guard let url = URL(string: endpoint) else {
            throw FutureImpactServiceError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        let encoder = JSONEncoder()
        urlRequest.httpBody = try? encoder.encode(request)

        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let response = try JSONDecoder().decode(FutureImpactResponse.self, from: data)
            return response
        } catch let error as DecodingError {
            throw FutureImpactServiceError.decodingError(error)
        } catch {
            throw FutureImpactServiceError.networkError(error)
        }
    }
}
