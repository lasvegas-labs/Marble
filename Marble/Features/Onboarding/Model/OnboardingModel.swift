//
//  OnboardingModel.swift
//  Marble
//
//  Created by Sande Effendi on 10/08/26.
//

import Foundation

struct OnboardingPage: Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String

    static let introduction = [
        OnboardingPage(
            id: 0,
            title: "The \"One Thing\" Trap",
            subtitle: "You only meant to check one thing, but somehow you were still scrolling an hour later."
        ),
        OnboardingPage(
            id: 1,
            title: "Just a Quick Scroll",
            subtitle: "A quick peek quickly turns into a blur as you realize how much time has passed."
        ),
        OnboardingPage(
            id: 2,
            title: "Take Control",
            subtitle: "Don't let a \"five-minute break\" dictate how the rest of your day unfolds."
        ),
        OnboardingPage(
            id: 3,
            title: "Reclaim Your Time",
            subtitle: "Get your time back and start turning your lost scrolling into moments that truly matter."
        ),
    ]
}
