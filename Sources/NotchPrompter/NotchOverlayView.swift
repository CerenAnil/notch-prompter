import SwiftUI
import AppKit

// MARK: - Outer SwiftUI shell

struct NotchOverlayView: View {
    @EnvironmentObject var state: PrompterState
    @State private var offset: CGFloat = 0
    var body: some View {
        let notchHeight = NSScreen.main?.safeAreaInsets.top ?? 0

        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.07, green: 0.07, blue: 0.07).opacity(0.96))

            VStack(spacing: 0) {
                // blank zone so text starts below the camera notch
                Color.clear.frame(height: notchHeight)
                PrompterTextView(
                    text: state.scriptText,
                    fontName: state.selectedFont,
                    fontSize: state.fontSize,
                    scrollOffset: offset
                )
            }
            .padding(4)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(width: 340, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onReceive(
            Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()
        ) { _ in
            guard state.isScrolling else { return }
            offset += CGFloat(state.scrollSpeed / 60.0)
        }
        .onChange(of: state.resetToken) { _ in
            offset = 0
        }
    }
}

// MARK: - AppKit text view (reliable scroll control)

struct PrompterTextView: NSViewRepresentable {
    let text: String
    let fontName: String
    let fontSize: CGFloat
    let scrollOffset: CGFloat

    class Coordinator {
        var lastText = ""
        var lastFontName = ""
        var lastFontSize: CGFloat = 0
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.drawsBackground = false
        textView.textColor = .white
        textView.textContainerInset = NSSize(width: 12, height: 8)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 332, height: CGFloat.greatestFiniteMagnitude)

        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        let coord = context.coordinator

        // Only rebuild attributed string when content/style actually changes
        if text != coord.lastText || fontName != coord.lastFontName || fontSize != coord.lastFontSize {
            coord.lastText = text
            coord.lastFontName = fontName
            coord.lastFontSize = fontSize

            let font = NSFont(name: fontName, size: fontSize) ?? NSFont.systemFont(ofSize: fontSize)
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5

            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor.white,
                .paragraphStyle: style,
            ]
            textView.textStorage?.setAttributedString(NSAttributedString(string: text, attributes: attrs))

        }

        // Scroll to exact position - offset=0 means top (beginning of script)
        scrollView.contentView.scroll(to: NSPoint(x: 0, y: scrollOffset))
        scrollView.reflectScrolledClipView(scrollView.contentView)
    }
}
