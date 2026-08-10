//
//  HomeView.swift
//
//  Created by Sande Effendi on 03/08/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: HomeViewModel

    // buat contructor agar bisa inject view model di home route builder
    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Ini adalah homescreen")

            Button(action: viewModel.sayHelloFromHome) {
                Text("Print Hello World!")
            }
            .buttonStyle(.borderedProminent)
            
            Button(action: {
                router.push(.orb)
            }) {
                Text("View Orb POC")
            }
            .buttonStyle(.bordered)
        }
    }
}
