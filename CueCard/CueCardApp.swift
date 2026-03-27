import SwiftUI

@main
struct CueCardApp: App {
    @State private var settings = AppSettings()
    @State private var storage = ScriptStorage()
    @State private var scrollEngine = ScrollEngine()
    @State private var windowManager = WindowManager()

    var body: some Scene {
        MenuBarExtra("CueCard", systemImage: "text.below.photo") {
            MenuBarView()
                .environment(settings)
                .environment(storage)
                .environment(scrollEngine)
                .environment(windowManager)
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
        }
        .windowStyle(.plain)
        .windowLevel(.floating)
        .defaultSize(width: 400, height: 300)
        .windowResizability(.contentMinSize)

        Window("Script Editor", id: "editor") {
            ScriptEditorView()
                .environment(settings)
                .environment(storage)
        }
        .defaultSize(width: 500, height: 600)
    }
}
