import SwiftUI
import AppKit

/// Holds a reference to the NSWindow so we can resize it directly.
@Observable
@MainActor
final class WindowManager {
    var window: NSWindow?

    func resize(width: CGFloat, height: CGFloat) {
        guard let window else { return }
        // Pin top-left: keep maxY and minX constant
        let topY = window.frame.maxY
        let x = window.frame.origin.x
        let newOriginY = topY - height
        let newFrame = NSRect(x: x, y: newOriginY, width: width, height: height)
        window.setFrame(newFrame, display: true, animate: false)
    }

    func setup(window: NSWindow) {
        self.window = window
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.isMovableByWindowBackground = true
        window.collectionBehavior.insert(.canJoinAllSpaces)
        window.setFrameAutosaveName("CueCardTeleprompter")
        if UserDefaults.standard.string(forKey: "NSWindow Frame CueCardTeleprompter") == nil {
            positionNearNotch()
        }
    }

    func positionNearNotch() {
        guard let window, let screen = NSScreen.main?.frame else { return }
        let x = screen.midX - window.frame.width / 2
        let y = screen.maxY - window.frame.height
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}

struct WindowAccessor: NSViewRepresentable {
    var onWindow: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                onWindow(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

enum WindowSnap {
    static let threshold: CGFloat = 20

    static func snapPosition(for frame: NSRect, in screen: NSRect) -> NSPoint? {
        var snapped = frame.origin
        var didSnap = false

        if abs(frame.minX - screen.minX) < threshold {
            snapped.x = screen.minX
            didSnap = true
        }
        if abs(frame.maxX - screen.maxX) < threshold {
            snapped.x = screen.maxX - frame.width
            didSnap = true
        }
        if abs(frame.maxY - screen.maxY) < threshold {
            snapped.y = screen.maxY - frame.height
            didSnap = true
        }
        if abs(frame.minY - screen.minY) < threshold {
            snapped.y = screen.minY
            didSnap = true
        }

        let screenCenterX = screen.midX
        let frameCenterX = frame.midX
        if abs(frameCenterX - screenCenterX) < threshold {
            snapped.x = screenCenterX - frame.width / 2
            didSnap = true
        }

        return didSnap ? snapped : nil
    }
}
