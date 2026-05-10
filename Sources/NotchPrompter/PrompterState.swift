import SwiftUI

class PrompterState: ObservableObject {
    @Published var scriptText: String = """
Paste your script here and press Play to begin scrolling.

Use the Speed and Font Size sliders to match your reading pace.
Press Space to pause, arrow keys to adjust speed, and Up to restart.
"""

    @Published var scrollSpeed: Double = 40.0
    @Published var fontSize: Double = 13.0
    @Published var selectedFont: String = "Helvetica Neue"
    @Published var isScrolling: Bool = false
    @Published var resetToken: Int = 0

    let availableFonts = [
        "Helvetica Neue",
        "Georgia",
        "Courier New",
        "Arial",
        "Times New Roman",
        "Verdana",
        "Futura",
        "Gill Sans",
    ]

    func resetScroll() {
        isScrolling = false
        resetToken += 1
    }
}
