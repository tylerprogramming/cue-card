# CueCard

A macOS teleprompter app that floats near your camera so you can read scripts while maintaining eye contact. Built with SwiftUI for macOS 15+.

## Features

- **Floating overlay** - always-on-top borderless window with frosted glass background
- **Auto-scroll** - smooth 60fps scrolling at adjustable speed (0.1x - 5.0x)
- **Menu bar app** - no dock icon, all controls live in the menu bar
- **Draggable** - drag the window anywhere on screen
- **Resizable** - adjust width and height from the menu bar or drag edges
- **Snap to notch** - defaults to top-center near your camera on first launch
- **Markdown stripping** - load .md scripts and stage directions are removed automatically
- **Keyboard shortcuts** - space (play/pause), arrows (scroll), escape (hide)
- **Persistent settings** - font size, opacity, speed, window size all saved between launches
- **Works across Spaces** - teleprompter follows you to any desktop

## Requirements

- macOS 15.0+ (Sequoia)
- Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Setup

```bash
git clone <repo-url> && cd cuecard
xcodegen generate
open CueCard.xcodeproj
```

Hit Cmd+R in Xcode to build and run.

### Command line build

```bash
xcodegen generate
xcodebuild -scheme CueCard -configuration Debug build
```

The built app will be in `~/Library/Developer/Xcode/DerivedData/CueCard-*/Build/Products/Debug/CueCard.app`.

## Usage

1. Click the CueCard icon in the menu bar
2. Click **Edit Script** to paste or load a script (.md or .txt)
3. Click **Show Teleprompter** to open the floating window
4. Press **Space** to start auto-scrolling
5. Adjust speed, font size, opacity, and window size from the menu bar

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Space | Play / Pause scroll |
| Up Arrow | Scroll up |
| Down Arrow | Scroll down |
| Escape | Hide teleprompter |
| Cmd+T | Toggle teleprompter (from menu bar) |

## Project Structure

```
CueCard/
  CueCardApp.swift          # App entry point, window scenes
  Models/
    AppSettings.swift        # User preferences (persisted)
    Script.swift             # Script data model
  Views/
    TeleprompterWindow.swift # Floating overlay with scrolling text
    ScriptEditorView.swift   # Script editor with file import
    MenuBarView.swift        # Menu bar control panel
  Services/
    ScrollEngine.swift       # Timer-driven auto-scroll
    WindowManager.swift      # NSWindow control, snap-to-edge
    ScriptStorage.swift      # JSON persistence
    MarkdownStripper.swift   # Clean markdown for display
```

## License

MIT
