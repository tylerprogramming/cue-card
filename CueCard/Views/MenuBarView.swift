import SwiftUI

struct MenuBarView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(ScriptStorage.self) private var storage
    @Environment(ScrollEngine.self) private var scrollEngine
    @Environment(WindowManager.self) private var windowManager
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @State private var teleprompterVisible = false

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

            HStack {
                Text("Speed")
                    .font(.caption)
                Slider(value: $settings.scrollSpeed, in: 0.1...5.0, step: 0.1)
                    .frame(width: 120)
                Text(String(format: "%.1fx", settings.scrollSpeed))
                    .font(.caption.monospacedDigit())
                    .frame(width: 30)
            }

            Divider()

            HStack {
                Text("Font Size")
                    .font(.caption)
                Slider(value: $settings.fontSize, in: 16...72, step: 2)
                    .frame(width: 100)
                Text("\(Int(settings.fontSize))pt")
                    .font(.caption.monospacedDigit())
                    .frame(width: 35)
            }

            HStack {
                Text("Opacity")
                    .font(.caption)
                Slider(value: $settings.backgroundOpacity, in: 0.1...1.0, step: 0.05)
                    .frame(width: 100)
                Text("\(Int(settings.backgroundOpacity * 100))%")
                    .font(.caption.monospacedDigit())
                    .frame(width: 35)
            }

            HStack {
                Text("Width")
                    .font(.caption)
                Slider(value: $settings.windowWidth, in: 250...800, step: 10)
                    .frame(width: 100)
                Text("\(Int(settings.windowWidth))")
                    .font(.caption.monospacedDigit())
                    .frame(width: 35)
            }

            HStack {
                Text("Height")
                    .font(.caption)
                Slider(value: $settings.windowHeight, in: 150...600, step: 10)
                    .frame(width: 100)
                Text("\(Int(settings.windowHeight))")
                    .font(.caption.monospacedDigit())
                    .frame(width: 35)
            }

            Divider()

            Button(teleprompterVisible ? "Hide Teleprompter" : "Show Teleprompter") {
                if teleprompterVisible {
                    scrollEngine.pause()
                    dismissWindow(id: "teleprompter")
                } else {
                    openWindow(id: "teleprompter")
                }
                teleprompterVisible.toggle()
            }
            .keyboardShortcut("t", modifiers: .command)

            Button("Edit Script") {
                openWindow(id: "editor")
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
        .onChange(of: settings.scrollSpeed) { scrollEngine.speed = settings.scrollSpeed }
        .onChange(of: settings.windowWidth) {
            windowManager.resize(width: settings.windowWidth, height: settings.windowHeight)
            settings.save()
        }
        .onChange(of: settings.windowHeight) {
            windowManager.resize(width: settings.windowWidth, height: settings.windowHeight)
            settings.save()
        }
    }
}
