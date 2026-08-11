//
//  SetProfileView.swift
//  Marble
//
//  Created by Sande Effendi on 11/08/26.
//

import SwiftUI

struct SetupProfileView: View {
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrapperValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("ini adalah setup profile view")
        }
    }
}
