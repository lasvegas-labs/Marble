//
//  ReportView.swift
//  Marble
//
//  Created by Amalia Sandi Alzahrah on 11/08/26.
//

import SwiftUI

struct ReportView: View {
    @StateObject private var viewModel: ReportViewModel

    init(viewModel: ReportViewModel = ReportViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            Spacer()
            Text("Report Page")
                .font(.title2.weight(.medium))
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Report")
    }
}
