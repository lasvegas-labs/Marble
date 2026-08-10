//
//  OnboardingViewModel.swift
//  Marble
//
//  Created by Sande Effendi on 10/08/26.
//

import Combine

final class OnboardingViewModel: ObservableObject {
    let pages = OnboardingPage.introduction

    @Published var selectedPageIndex = 0

    func advance() {
        selectedPageIndex = (selectedPageIndex + 1) % pages.count
    }
}
