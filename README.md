# NotchPrompter

A lightweight macOS teleprompter that scrolls your script inside the camera notch area of your MacBook. No Xcode required - runs directly from the terminal with Swift Package Manager.

![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-orange)

---

## Features

- Scrolls your script in a dark overlay anchored to the MacBook notch
- Automatically positions text below the camera so nothing is obscured
- Adjustable scroll speed, font size, and font family
- Global keyboard shortcuts that work in any app (Accessibility permission required)
- Edit your script in `prompter.txt` - changes reload live without restarting
- No App Store, no subscription, no external dependencies

---

## Requirements

- MacBook with a notch (Pro 14"/16", Air M2/M3 or later)
- macOS 12.0 or later
- Xcode Command Line Tools

If you don't have the command line tools installed:

```bash
xcode-select --install
```

---

## Installation

Clone the repository and run:

```bash
git clone https://github.com/CerenAnil/notch-prompter.git
cd NotchPrompter
swift run
```

The first build takes about 30-60 seconds. Subsequent launches are fast.

---

## Usage

### Control Panel

When the app launches, a control panel window opens where you can:

- **Paste or type your script** in the text editor
- **Adjust scroll speed** with the Speed slider (10-300 pt/s)
- **Adjust font size** with the Font Size slider (9-28 pt)
- **Choose a font** from the dropdown

The dark overlay appears at the top of your screen near the notch immediately on launch.

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Space` | Play / Pause |
| `Left Arrow` | Decrease speed |
| `Right Arrow` | Increase speed |
| `Up Arrow` | Restart from beginning |

Shortcuts work **in any app** once Accessibility permission is granted (see below). They also work locally when the NotchPrompter window is focused, without any permission.

### Enabling Global Shortcuts

To use shortcuts while presenting (i.e. when another app like Keynote or a browser is in front):

1. Click **Enable Global Shortcuts** in the control panel header
2. macOS will open System Settings > Privacy & Security > Accessibility
3. Toggle NotchPrompter on
4. Quit and relaunch the app

---

## Project Structure

```
NotchPrompter/
├── Package.swift                          - Swift Package manifest
└── Sources/
    └── NotchPrompter/
        ├── NotchPrompterApp.swift         - App entry point
        ├── AppDelegate.swift              - Window setup, keyboard shortcuts
        ├── PrompterState.swift            - Shared observable state, file watcher
        ├── prompter.txt                   - Your script - edit this file directly
        ├── ControlPanelView.swift         - Settings and editor UI
        └── NotchOverlayView.swift         - Notch overlay with scrolling text
```

---

## Tech Stack

- **Swift + SwiftUI** - UI and app lifecycle
- **AppKit (NSTextView, NSScrollView)** - Reliable text rendering and scroll control
- **NSEvent global monitor** - System-wide keyboard shortcuts
- **NSScreen.safeAreaInsets** - Reads the exact notch height per MacBook model

No third-party dependencies.

---

## Changing the Script

Edit `Sources/NotchPrompter/prompter.txt` in any text editor and save - the prompter reloads the text live without restarting the app.

---

## Known Limitations

- The overlay is designed for MacBooks with a notch. On Macs without a notch it still works but appears as a plain dark popup at the top center of the screen.
- Global shortcuts require Accessibility permission and a restart after granting it.
- The app is not sandboxed (required for global keyboard monitoring) and is not meant for App Store distribution.
