import SwiftUI

struct MenuBarView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(ScriptStorage.self) private var storage
    @Environment(ScrollEngine.self) private var scrollEngine
    @Environment(WindowManager.self) private var windowManager
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        @Bindable var settings = settings

        VStack(spacing: 8) {
            Text("CueCard")
                .font(.headline)

            if let script = storage.currentScript {
                Text(script.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            HStack {
                Button(scrollEngine.isScrolling ? "Pause" : "Play") {
                    scrollEngine.toggle()
                }
                .keyboardShortcut(.space, modifiers: [])

                Button("Reset") {
                    scrollEngine.reset()
                }
            }

            SettingsSlider(label: "Speed", value: $settings.scrollSpeed, range: 0.1...5.0, step: 0.1, format: "%.1fx", width: 120)

            Divider()

            SettingsSlider(label: "Font Size", value: $settings.fontSize, range: 16...72, step: 2, format: "%.0fpt")
            SettingsSlider(label: "Opacity", value: $settings.backgroundOpacity, range: 0.1...1.0, step: 0.05, format: "%.0f%%", scale: 100)
            SettingsSlider(label: "Width", value: $settings.windowWidth, range: 250...800, step: 10, format: "%.0f")
            SettingsSlider(label: "Height", value: $settings.windowHeight, range: 150...600, step: 10, format: "%.0f")

            Divider()

            Button(windowManager.isVisible ? "Hide Teleprompter" : "Show Teleprompter") {
                if windowManager.isVisible {
                    scrollEngine.pause()
                    if windowManager.window != nil {
                        windowManager.hide()
                    } else {
                        dismissWindow(id: "teleprompter")
                    }
                } else {
                    if windowManager.window != nil {
                        windowManager.show()
                    } else {
                        openWindow(id: "teleprompter")
                    }
                }
            }
            .keyboardShortcut("t", modifiers: .command)

            Button("Edit Script") {
                if let editorWindow = NSApp.windows.first(where: { $0.title.contains("Script Editor") }) {
                    editorWindow.makeKeyAndOrderFront(nil)
                    NSApp.activate(ignoringOtherApps: true)
                } else {
                    openWindow(id: "editor")
                    NSApp.activate(ignoringOtherApps: true)
                }
            }

            Divider()

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding()
        .frame(width: 240)
        .onChange(of: settings.fontSize) { settings.save() }
        .onChange(of: settings.backgroundOpacity) { settings.save() }
        .onChange(of: settings.scrollSpeed) {
            scrollEngine.speed = settings.scrollSpeed
            settings.save()
        }
        .onChange(of: settings.windowWidth) { resizeAndSave() }
        .onChange(of: settings.windowHeight) { resizeAndSave() }
    }

    private func resizeAndSave() {
        windowManager.resize(width: settings.windowWidth, height: settings.windowHeight)
        windowManager.savePosition()
        settings.save()
    }
}

private struct SettingsSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let format: String
    var scale: Double = 1
    var width: CGFloat = 100

    init(label: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, format: String, scale: Double = 1, width: CGFloat = 100) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.format = format
        self.scale = scale
        self.width = width
    }

    init(label: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, step: CGFloat, format: String, scale: Double = 1, width: CGFloat = 100) {
        self.label = label
        self._value = Binding(get: { Double(value.wrappedValue) }, set: { value.wrappedValue = CGFloat($0) })
        self.range = Double(range.lowerBound)...Double(range.upperBound)
        self.step = Double(step)
        self.format = format
        self.scale = scale
        self.width = width
    }

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
            Slider(value: $value, in: range, step: step)
                .frame(width: width)
            Text(String(format: format, value * scale))
                .font(.caption.monospacedDigit())
                .frame(width: 35)
        }
    }
}
