import SwiftUI
import AppKit

@main
struct PromptSaverApp: App {
    @StateObject private var store = DataStore()
    @StateObject private var localeManager = LocaleManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(localeManager)
                .onAppear {
                    if let path = Bundle.module.path(forResource: "icon", ofType: "png"),
                       let image = NSImage(contentsOfFile: path) {
                        NSApp.applicationIconImage = image
                    }
                }
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 900, height: 600)

        Settings {
            SettingsView()
                .environmentObject(localeManager)
        }
    }
}
