import HotKey

@MainActor
final class GlobalHotkeys {
    private var hotkeys: [HotKey] = []
    private var registered = false

    func register(scrollEngine: ScrollEngine, windowManager: WindowManager) {
        guard !registered else { return }
        registered = true

        // Cmd+Shift+T: Show/Hide teleprompter
        let toggle = HotKey(key: .t, modifiers: [.command, .shift])
        toggle.keyDownHandler = { [weak windowManager, weak scrollEngine] in
            guard let wm = windowManager else { return }
            if wm.isVisible {
                scrollEngine?.pause()
                wm.hide()
            } else {
                wm.show()
            }
        }
        hotkeys.append(toggle)

        // Cmd+Shift+Space: Play/Pause
        let playPause = HotKey(key: .space, modifiers: [.command, .shift])
        playPause.keyDownHandler = { [weak scrollEngine] in
            scrollEngine?.toggle()
        }
        hotkeys.append(playPause)

        // Cmd+Shift+R: Reset
        let reset = HotKey(key: .r, modifiers: [.command, .shift])
        reset.keyDownHandler = { [weak scrollEngine] in
            scrollEngine?.reset()
        }
        hotkeys.append(reset)

        // Cmd+Shift+Left: Previous section
        let prev = HotKey(key: .leftArrow, modifiers: [.command, .shift])
        prev.keyDownHandler = { [weak scrollEngine] in
            scrollEngine?.previousSection()
        }
        hotkeys.append(prev)

        // Cmd+Shift+Right: Next section
        let next = HotKey(key: .rightArrow, modifiers: [.command, .shift])
        next.keyDownHandler = { [weak scrollEngine] in
            scrollEngine?.nextSection()
        }
        hotkeys.append(next)
    }

    func unregister() {
        hotkeys.removeAll()
        registered = false
    }
}
