import SwiftUI
import AppKit

struct TeleprompterWindow: View {
    @Environment(AppSettings.self) private var settings
    @Environment(ScriptStorage.self) private var storage
    @Environment(ScrollEngine.self) private var scrollEngine

    @State private var cachedDisplayText: String = ""

    var body: some View {
        ZStack {
            VisualEffectBackground(opacity: settings.backgroundOpacity)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                DragHandleBar()

                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            Spacer(minLength: geometry.size.height / 3)

                            Text(cachedDisplayText)
                                .font(.system(size: settings.fontSize, weight: .medium, design: .default))
                                .foregroundStyle(settings.textColor)
                                .multilineTextAlignment(.center)
                                .lineSpacing(settings.fontSize * 0.4)
                                .padding(.horizontal, 24)
                                .frame(maxWidth: .infinity)

                            Spacer(minLength: geometry.size.height / 2)
                        }
                    }
                    .scrollPosition(Binding(
                        get: { ScrollPosition(point: CGPoint(x: 0, y: scrollEngine.currentOffset)) },
                        set: { _ in }
                    ))
                }

                if scrollEngine.isScrolling {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.red)
                            .frame(width: 6, height: 6)
                        Text("SCROLLING \(String(format: "%.1fx", scrollEngine.speed))")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 6)
                    .transition(.opacity)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .frame(width: settings.windowWidth, height: settings.windowHeight)
        .onKeyPress(.space) {
            scrollEngine.toggle()
            return .handled
        }
        .onKeyPress(.upArrow) {
            scrollEngine.nudge(by: -30)
            return .handled
        }
        .onKeyPress(.downArrow) {
            scrollEngine.nudge(by: 30)
            return .handled
        }
        .onKeyPress(.escape) {
            NSApp.keyWindow?.close()
            return .handled
        }
        .focusable()
        .animation(.easeInOut(duration: 0.2), value: scrollEngine.isScrolling)
        .onAppear { updateDisplayText() }
        .onChange(of: storage.currentScript?.body) { updateDisplayText() }
    }

    private func updateDisplayText() {
        guard let script = storage.currentScript else {
            cachedDisplayText = "No script loaded.\n\nClick the CueCard menu bar icon to load a script."
            return
        }
        cachedDisplayText = MarkdownStripper.strip(script.body)
    }
}

private struct DragHandleBar: View {
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(.white.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 6)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .gesture(WindowDragGesture())
    }
}

struct VisualEffectBackground: NSViewRepresentable {
    var opacity: Double

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.state = .active
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.alphaValue = CGFloat(opacity)
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.alphaValue = CGFloat(opacity)
    }
}
