import HotKey

@MainActor
final class GlobalHotkeys {
    private var hotkeys: [HotKey] = []
    private var registered = false

    func register(scrollEngine: ScrollEngine, windowManager: WindowManager, settings: AppSettings) {
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

        // Cmd+Shift+Up: Increase scroll speed
        let speedUp = HotKey(key: .upArrow, modifiers: [.command, .shift])
        speedUp.keyDownHandler = { [weak scrollEngine, weak settings] in
            guard let engine = scrollEngine, let s = settings else { return }
            let newSpeed = min(5.0, engine.speed + 0.5)
            engine.speed = newSpeed
            s.scrollSpeed = newSpeed
            s.save()
        }
        hotkeys.append(speedUp)

        // Cmd+Shift+Down: Decrease scroll speed
        let speedDown = HotKey(key: .downArrow, modifiers: [.command, .shift])
        speedDown.keyDownHandler = { [weak scrollEngine, weak settings] in
            guard let engine = scrollEngine, let s = settings else { return }
            let newSpeed = max(0.1, engine.speed - 0.5)
            engine.speed = newSpeed
            s.scrollSpeed = newSpeed
            s.save()
        }
        hotkeys.append(speedDown)

        // Cmd+Shift+=: Increase font size
        let fontUp = HotKey(key: .equal, modifiers: [.command, .shift])
        fontUp.keyDownHandler = { [weak settings] in
            guard let s = settings else { return }
            s.fontSize = min(72, s.fontSize + 2)
            s.save()
        }
        hotkeys.append(fontUp)

        // Cmd+Shift+-: Decrease font size
        let fontDown = HotKey(key: .minus, modifiers: [.command, .shift])
        fontDown.keyDownHandler = { [weak settings] in
            guard let s = settings else { return }
            s.fontSize = max(16, s.fontSize - 2)
            s.save()
        }
        hotkeys.append(fontDown)
    }

    func unregister() {
        hotkeys.removeAll()
        registered = false
    }
}
