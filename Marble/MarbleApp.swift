//
//  MarbleApp.swift
//
//  Created by Muhammad Fahmi on 28/07/26.
//

import SwiftUI
import SwiftData
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let url = URL(string: "marble://recommendation") {
            UIApplication.shared.open(url)
        }
        completionHandler()
    }
}

@main
struct MarbleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var router = AppRouter()
    @State private var isSplashVisible = true
    @State private var isHandoffStarted = false

    private let handoffDuration = 0.70
    private let splashFadeDuration = 0.16

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .opacity(isHandoffStarted ? 1 : 0)
                    .animation(
                        reduceMotion ? nil : .easeIn(duration: handoffDuration),
                        value: isHandoffStarted
                    )
                    .allowsHitTesting(isHandoffStarted && !isSplashVisible)
                    .accessibilityHidden(!isHandoffStarted || isSplashVisible)

                if isSplashVisible {
                    SplashView(onFinished: beginHandoff)
                        .opacity(isHandoffStarted ? 0 : 1)
                        .animation(
                            reduceMotion ? nil : .easeOut(duration: splashFadeDuration),
                            value: isHandoffStarted
                        )
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .environmentObject(router)
            .task(id: isHandoffStarted) {
                guard isHandoffStarted, !reduceMotion else { return }

                try? await Task.sleep(for: .seconds(handoffDuration))
                guard !Task.isCancelled else { return }

                withAnimation(.easeOut(duration: splashFadeDuration)) {
                    isSplashVisible = false
                }
            }
        }
        .modelContainer(for: SetupProfileModel.self)
    }

    private func beginHandoff() {
        guard !isHandoffStarted else { return }

        isHandoffStarted = true
        if reduceMotion {
            isSplashVisible = false
        }
    }
}
