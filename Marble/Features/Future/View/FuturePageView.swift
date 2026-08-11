//
//  FuturePageView.swift
//  Marble
//
//  Created by Amalia Sandi Alzahrah on 11/08/26.
//

import SwiftUI

struct FuturePageView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: FutureViewModel

    init(viewModel: FutureViewModel = FutureViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header with custom Back Button
            HStack {
                Button(action: { router.pop() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                        Text("Back")
                    }
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Spacer()
            
            // Stats header
            VStack(spacing: 6) {
                Text("19h 17m")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                (Text("If Nothing ")
                    .foregroundColor(.secondary)
                 + Text("Changes")
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                 + Text(" for the Next ")
                    .foregroundColor(.secondary)
                 + Text("3 Years")
                    .fontWeight(.bold)
                    .foregroundColor(.primary))
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                
                Text("that's...")
                    .font(.system(.title3, design: .rounded))
                    .italic()
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            // Neon Glow Card
            ZStack {
                // Soft blue radial neon blur behind the card
                Circle()
                    .fill(Color.blue.opacity(0.18))
                    .frame(width: 260, height: 260)
                    .blur(radius: 50)
                
                // Translucent Glassmorphism Card
                VStack(spacing: 30) {
                    VStack(spacing: 4) {
                        Text("3.008 H - 125 D")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("your time lost")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    // Center moon icon
                    Image(systemName: "moon.fill")
                        .font(.system(size: 85))
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                    
                    VStack(spacing: 8) {
                        Text("SLEEP")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Shorter Duration & Poorer Quality")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.vertical, 35)
                .padding(.horizontal, 25)
                .frame(width: 265, height: 380)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(uiColor: .systemBackground).opacity(0.85))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.45), lineWidth: 1.5)
                )
                .shadow(color: Color.blue.opacity(0.1), radius: 20, x: 0, y: 10)
            }
            
            Spacer()
            
            // Footer Text
            (Text("Choose Your ")
                .foregroundColor(.primary)
             + Text("Future")
                .fontWeight(.bold)
                .foregroundColor(.primary))
            .font(.system(.title2, design: .rounded))
            .padding(.bottom, 30)
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }
}
