import SwiftUI

@main
struct NotchPrompterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup("NotchPrompter") {
            ControlPanelView()
                .environmentObject(appDelegate.state)
        }
    }
}
