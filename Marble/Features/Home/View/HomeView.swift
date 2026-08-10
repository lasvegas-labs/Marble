//
//  HomeView.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    // buat contructor agar bisa inject view model di home route builder
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Text("Ini adalah homescreen")

        Button(action: viewModel.sayHelloFromHome) {
            Text("Print Hello World!")

        }
        .buttonStyle(.borderedProminent)
    }
}
