import SwiftUI

@main
struct PromptSaverApp: App {
    @StateObject private var store = DataStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 900, height: 600)
    }
}
