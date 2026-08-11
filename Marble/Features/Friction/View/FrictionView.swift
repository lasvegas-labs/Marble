//
//  FrictionView.swift
//  Marble
//

import SwiftUI

struct FrictionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: FrictionViewModel

    init(viewModel: FrictionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Mascot
            Image("ShieldIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 228, height: 228)
                .clipShape(RoundedRectangle(cornerRadius: 48, style: .continuous))
                .padding(.bottom, 16)

            // Title
            Text(viewModel.title)
                .font(.title2) // Figma looks like title2/title with bold weight
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

            // Supporting Message
            Text(viewModel.usageMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            // Friction Actions
            VStack(spacing: 16) {
                Button(action: {
                    router.push(.recommendation)
                }) {
                    Text(viewModel.recommendationTitle)
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .background(Color(UIColor.secondarySystemBackground))
                .foregroundColor(.primary)
                .cornerRadius(14)
                
                Button(action: {
                    dismiss()
                }) {
                    Text(viewModel.continueTitle)
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(24)
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        FrictionView(viewModel: FrictionViewModel())
            .environmentObject(AppRouter())
    }
}
