import SwiftUI

@main
struct PromptSaverApp: App {
    @StateObject private var store = DataStore()
    @StateObject private var localeManager = LocaleManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(localeManager)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 900, height: 600)

        Settings {
            SettingsView()
                .environmentObject(localeManager)
        }
    }
}
