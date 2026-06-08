import SwiftUI

class PrompterState: ObservableObject {
    @Published var scriptText: String = "PASTE YOUR TEXT"

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

    private let txtPath = "/Users/cerenanil/Fork Default/prompter/NotchPrompter/Sources/NotchPrompter/prompter.txt"
    private var fileWatcher: DispatchSourceFileSystemObject?
    private var watchedFD: Int32 = -1

    init() {
        loadText()
        startWatching()
    }

    deinit {
        fileWatcher?.cancel()
        if watchedFD != -1 { close(watchedFD) }
    }

    func resetScroll() {
        isScrolling = false
        resetToken += 1
    }

    private func loadText() {
        let text = (try? String(contentsOfFile: txtPath, encoding: .utf8)) ?? "PASTE YOUR TEXT"
        DispatchQueue.main.async { self.scriptText = text }
    }

    private func startWatching() {
        let fd = open(txtPath, O_EVTONLY)
        guard fd != -1 else { return }
        watchedFD = fd

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .rename, .delete],
            queue: DispatchQueue.global(qos: .background)
        )
        source.setEventHandler { [weak self] in
            self?.loadText()
            // Re-attach watcher because atomic saves replace the inode
            self?.fileWatcher?.cancel()
            self?.watchedFD = -1
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
                self?.startWatching()
            }
        }
        source.setCancelHandler { close(fd) }
        source.resume()
        fileWatcher = source
    }
}
