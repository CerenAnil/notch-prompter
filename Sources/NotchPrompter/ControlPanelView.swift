import SwiftUI

struct ControlPanelView: View {
    @EnvironmentObject var state: PrompterState
    @State private var accessibilityGranted: Bool = AXIsProcessTrusted()

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider()
            scriptEditor
            Divider()
            controlsBar
        }
        .onAppear {
            accessibilityGranted = AXIsProcessTrusted()
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("NotchPrompter")
                    .font(.title2.bold())
                Text("Scrolls your script near the MacBook notch")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()

            if !accessibilityGranted {
                Button("Enable Global Shortcuts") {
                    let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true] as CFDictionary
                    AXIsProcessTrustedWithOptions(options)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        accessibilityGranted = AXIsProcessTrusted()
                    }
                }
                .buttonStyle(.bordered)
                .tint(.orange)
            }

            Button(action: { state.resetScroll() }) {
                Label("Restart", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.bordered)

            Button(action: { state.isScrolling.toggle() }) {
                Label(
                    state.isScrolling ? "Pause" : "Play",
                    systemImage: state.isScrolling ? "pause.fill" : "play.fill"
                )
                .frame(minWidth: 64)
            }
            .buttonStyle(.borderedProminent)
            .tint(state.isScrolling ? .orange : .green)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Script editor

    private var scriptEditor: some View {
        TextEditor(text: $state.scriptText)
            .font(.system(size: 13))
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Controls

    private var controlsBar: some View {
        VStack(spacing: 14) {
            HStack(spacing: 24) {
                sliderRow(
                    label: "Speed",
                    valueLabel: "\(Int(state.scrollSpeed)) pt/s",
                    value: $state.scrollSpeed,
                    range: 10...300,
                    step: 5,
                    color: .blue
                )
                sliderRow(
                    label: "Font Size",
                    valueLabel: "\(Int(state.fontSize)) pt",
                    value: $state.fontSize,
                    range: 9...28,
                    step: 1,
                    color: .purple
                )
            }

            HStack {
                Text("Font")
                    .font(.caption.bold())
                Picker("", selection: $state.selectedFont) {
                    ForEach(state.availableFonts, id: \.self) { font in
                        Text(font)
                            .font(.custom(font, size: 13))
                            .tag(font)
                    }
                }
                .frame(width: 200)

                Spacer()

                HStack(spacing: 14) {
                    ShortcutBadge(key: "Space", action: "Play/Pause")
                    ShortcutBadge(key: "< >", action: "Speed")
                    ShortcutBadge(key: "^", action: "Restart")
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func sliderRow(
        label: String,
        valueLabel: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).font(.caption.bold())
                Spacer()
                Text(valueLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            Slider(value: value, in: range, step: step)
                .tint(color)
        }
    }
}

struct ShortcutBadge: View {
    let key: String
    let action: String

    var body: some View {
        HStack(spacing: 4) {
            Text(key)
                .font(.caption.bold())
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.15))
                .cornerRadius(4)
            Text(action).font(.caption)
        }
    }
}
