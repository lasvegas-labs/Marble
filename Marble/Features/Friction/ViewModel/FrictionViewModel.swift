//
//  FrictionViewModel.swift
//  Marble
//

import Combine
import Foundation

final class FrictionViewModel: ObservableObject {
    var title: String {
        "Are you sure to continue?"
    }

    var usageMessage: String {
        "I have some fun and useful recommendation for you"
    }

    var continueTitle: String {
        "Continue Scrolling"
    }

    var recommendationTitle: String {
        "Show The Recommendation"
    }
}
