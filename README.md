# CueCard

A macOS teleprompter app that floats near your camera so you can read scripts while maintaining eye contact. Built with SwiftUI for macOS 15+.

## Features

- **Floating overlay** - always-on-top borderless window with frosted glass background
- **Auto-scroll** - smooth 60fps scrolling at adjustable speed (0.1x - 5.0x)
- **3-2-1 countdown** - countdown timer before scrolling starts so you can get settled
- **Section navigation** - split scripts with `##` headings or `---` dividers, jump between sections with left/right arrow keys
- **Read-here line** - centered guide line to help calibrate scroll speed to your speaking pace
- **Menu bar app** - no dock icon, all controls live in the menu bar
- **Draggable** - drag the window anywhere on screen, including right up to the notch
- **Resizable** - adjust width and height from the menu bar sliders
- **Show/Hide toggle** - hide the teleprompter without quitting, position is remembered
- **Markdown stripping** - load .md scripts and formatting/stage directions are removed automatically
- **Persistent settings** - font size, opacity, speed, window size, and position all saved between launches
- **Works across Spaces** - teleprompter follows you to any desktop

## Requirements

- macOS 15.0+ (Sequoia)
- Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Setup

```bash
git clone https://github.com/tylerprogramming/cue-card.git && cd cue-card
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
4. Press **Space** for a 3-2-1 countdown, then auto-scrolling begins
5. Adjust speed, font size, opacity, and window size from the menu bar

### Script Sections

Use `##` headings or `---` dividers in your script to create sections:

```markdown
## Intro

Hey everyone, welcome back to the channel.

---

## Main Topic

Today we're building something cool.

## Wrap Up

That's it, see you in the next one.
```

Sections show titles, dot dividers between them, and a section counter (e.g. "1/3") in the status bar. Use left/right arrow keys to jump between sections.

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Space | Start countdown / Pause scroll |
| Up Arrow | Scroll up |
| Down Arrow | Scroll down |
| Left Arrow | Previous section |
| Right Arrow | Next section |
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
    ScrollEngine.swift       # Timer-driven auto-scroll with countdown
    WindowManager.swift      # NSWindow control, position persistence
    ScriptStorage.swift      # JSON persistence
    MarkdownStripper.swift   # Markdown stripping and section parsing
```

## License

MIT
