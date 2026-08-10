//
//  MarbleApp
//
//  Created by Muhammad Fahmi on 28/07/26.
//

import SwiftUI

@main
struct MarbleApp: App {
    @StateObject private var router = AppRouter()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
        }
    }
}
