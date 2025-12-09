import SwiftUI

@main
struct SmartTrimApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        MenuBarExtra("SmartTrim", systemImage: "scissors") {
            MenuView(model: model)
        }
        .menuBarExtraStyle(.window)

        WindowGroup(id: "settings") {
            SettingsView(model: model)
        }
        .windowResizability(.contentSize)
    }
}
