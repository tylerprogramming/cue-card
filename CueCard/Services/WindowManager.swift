import SwiftUI
import AppKit

/// Borderless NSWindow subclass that removes macOS positioning constraints,
/// allowing the window to be placed anywhere including above the menu bar.
class UnconstrainedWindow: NSWindow {
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        return frameRect
    }
}

@Observable
@MainActor
final class WindowManager {
    var window: NSWindow?
    var isVisible: Bool = false

    private let positionKey = "cuecard_window_position"

    func resize(width: CGFloat, height: CGFloat) {
        guard let window else { return }
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
        isVisible = true

        // Restore saved position or default to near notch
        if let saved = loadPosition() {
            DispatchQueue.main.async {
                window.setFrame(saved, display: true)
            }
        } else {
            positionNearNotch()
        }
    }

    func show() {
        guard let window else { return }
        window.orderFront(nil)
        if let saved = loadPosition() {
            window.setFrame(saved, display: true)
        }
        isVisible = true
    }

    func hide() {
        guard let window else { return }
        savePosition()
        window.orderOut(nil)
        isVisible = false
    }

    func positionNearNotch() {
        guard let window, let screen = NSScreen.main?.frame else { return }
        let x = screen.midX - window.frame.width / 2
        let y = screen.maxY - window.frame.height
        window.setFrameOrigin(NSPoint(x: x, y: y))
        savePosition()
    }

    func savePosition() {
        guard let window else { return }
        let f = window.frame
        let dict: [String: CGFloat] = ["x": f.origin.x, "y": f.origin.y, "w": f.width, "h": f.height]
        UserDefaults.standard.set(dict, forKey: positionKey)
    }

    private func loadPosition() -> NSRect? {
        guard let dict = UserDefaults.standard.dictionary(forKey: positionKey),
              let x = dict["x"] as? CGFloat,
              let y = dict["y"] as? CGFloat,
              let w = dict["w"] as? CGFloat,
              let h = dict["h"] as? CGFloat else { return nil }
        return NSRect(x: x, y: y, width: w, height: h)
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
