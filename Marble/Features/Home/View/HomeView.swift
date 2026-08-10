//
//  HomeView.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Ini adalah homescreen")

            Button("Print Hello World!", action: viewModel.printGreeting)
                .buttonStyle(.borderedProminent)
        }
    }
}
