import SwiftUI

@main
struct CueCardApp: App {
    @State private var settings: AppSettings
    @State private var storage = ScriptStorage()
    @State private var scrollEngine: ScrollEngine
    @State private var windowManager = WindowManager()
    @State private var globalHotkeys = GlobalHotkeys()

    init() {
        let s = AppSettings()
        _settings = State(initialValue: s)
        let engine = ScrollEngine()
        engine.speed = s.scrollSpeed
        _scrollEngine = State(initialValue: engine)
    }

    private func ensureHotkeys() {
        globalHotkeys.register(scrollEngine: scrollEngine, windowManager: windowManager)
    }

    var body: some Scene {
        MenuBarExtra("CueCard", systemImage: "text.below.photo") {
            MenuBarView()
                .environment(settings)
                .environment(storage)
                .environment(scrollEngine)
                .environment(windowManager)
                .onAppear { ensureHotkeys() }
        }
        .menuBarExtraStyle(.window)

        Window("Teleprompter", id: "teleprompter") {
            TeleprompterWindow()
                .environment(settings)
                .environment(storage)
                .environment(scrollEngine)
                .background(WindowAccessor { window in
                    windowManager.setup(window: window)
                })
                .onAppear { ensureHotkeys() }
        }
        .windowStyle(.plain)
        .windowLevel(.floating)
        .defaultSize(width: 400, height: 300)
        .windowResizability(.contentMinSize)

        WindowGroup("Script Editor", id: "editor") {
            ScriptEditorView()
                .environment(settings)
                .environment(storage)
                .onAppear { ensureHotkeys() }
        }
        .defaultSize(width: 500, height: 600)
        .windowResizability(.contentMinSize)
    }
}
