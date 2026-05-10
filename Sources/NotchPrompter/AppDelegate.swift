import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    let state = PrompterState()
    private var overlayWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        createOverlayWindow()
        setupGlobalShortcuts()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func createOverlayWindow() {
        guard let screen = NSScreen.main else { return }

        let windowWidth: CGFloat = 340
        let windowHeight: CGFloat = 200
        let screenFrame = screen.frame

        let x = screenFrame.minX + (screenFrame.width - windowWidth) / 2
        let y = screenFrame.maxY - windowHeight

        let window = NSWindow(
            contentRect: NSRect(x: x, y: y, width: windowWidth, height: windowHeight),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        // Level 26 sits above the menu bar (kCGMainMenuWindowLevel = 24)
        window.level = NSWindow.Level(rawValue: 26)
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]

        let contentView = NSHostingView(
            rootView: NotchOverlayView()
                .environmentObject(state)
        )
        window.contentView = contentView
        window.orderFrontRegardless()

        self.overlayWindow = window
    }

    private func setupGlobalShortcuts() {
        let handler: (NSEvent) -> Void = { [weak self] event in
            guard let self else { return }
            DispatchQueue.main.async {
                switch event.keyCode {
                case 49:  self.state.isScrolling.toggle()
                case 123: self.state.scrollSpeed = max(10, self.state.scrollSpeed - 10)
                case 124: self.state.scrollSpeed = min(300, self.state.scrollSpeed + 10)
                case 126: self.state.resetScroll()
                default: break
                }
            }
        }

        // Local monitor - works when NotchPrompter window is focused, no permission needed
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handler(event)
            return event
        }

        // Global monitor - works in any app, requires Accessibility permission
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: handler)
    }
}
