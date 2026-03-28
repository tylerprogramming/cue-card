import SwiftUI
import AppKit

struct TeleprompterWindow: View {
    @Environment(AppSettings.self) private var settings
    @Environment(ScriptStorage.self) private var storage
    @Environment(ScrollEngine.self) private var scrollEngine

    @State private var sections: [ScriptSection] = []

    var body: some View {
        ZStack {
            VisualEffectBackground(opacity: settings.backgroundOpacity)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                DragHandleBar()

                ZStack {
                    GeometryReader { geometry in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                Spacer(minLength: geometry.size.height / 3)

                                ForEach(sections) { section in
                                    VStack(spacing: 8) {
                                        if let title = section.title {
                                            Text(title.uppercased())
                                                .font(.system(size: settings.fontSize * 0.5, weight: .bold, design: .default))
                                                .foregroundStyle(settings.textColor.opacity(0.4))
                                                .tracking(2)
                                                .padding(.top, section.id == 0 ? 0 : 20)
                                        }

                                        Text(section.body)
                                            .font(.system(size: settings.fontSize, weight: .medium, design: .default))
                                            .foregroundStyle(settings.textColor)
                                            .multilineTextAlignment(.center)
                                            .lineSpacing(settings.fontSize * 0.4)
                                            .padding(.horizontal, 24)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .id(section.id)
                                    .background(GeometryReader { sectionGeo in
                                        Color.clear.onAppear {
                                            if section.id < scrollEngine.sectionOffsets.count {
                                                let y = sectionGeo.frame(in: .named("scrollArea")).minY
                                                scrollEngine.sectionOffsets[section.id] = max(0, y - geometry.size.height / 3)
                                            }
                                        }
                                    })

                                    if section.id < sections.count - 1 {
                                        SectionDivider()
                                    }
                                }

                                Spacer(minLength: geometry.size.height / 2)
                            }
                        }
                        .coordinateSpace(name: "scrollArea")
                        .scrollPosition(Binding(
                            get: { ScrollPosition(point: CGPoint(x: 0, y: scrollEngine.currentOffset)) },
                            set: { _ in }
                        ))
                    }

                    ReadHereLine()

                    if scrollEngine.countdownValue > 0 {
                        CountdownOverlay(value: scrollEngine.countdownValue)
                    }
                }

                StatusBar(scrollEngine: scrollEngine, sectionCount: sections.count)
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
        .onKeyPress(.leftArrow) {
            scrollEngine.previousSection()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            scrollEngine.nextSection()
            return .handled
        }
        .onKeyPress(.escape) {
            NSApp.keyWindow?.close()
            return .handled
        }
        .focusable()
        .animation(.easeInOut(duration: 0.2), value: scrollEngine.isScrolling)
        .animation(.easeInOut(duration: 0.3), value: scrollEngine.countdownValue)
        .onAppear { updateSections() }
        .onChange(of: storage.currentScript?.body) { updateSections() }
    }

    private func updateSections() {
        guard let script = storage.currentScript else {
            sections = [ScriptSection(id: 0, title: nil, body: "No script loaded.\n\nClick the CueCard menu bar icon to load a script.")]
            return
        }
        sections = MarkdownStripper.sections(from: script.body)
        scrollEngine.sectionCount = sections.count
        scrollEngine.sectionOffsets = Array(repeating: 0, count: sections.count)
    }
}

private struct ReadHereLine: View {
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                Rectangle()
                    .fill(.white.opacity(0.15))
                    .frame(height: 1)
                Text("READ HERE")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.2))
                Rectangle()
                    .fill(.white.opacity(0.15))
                    .frame(height: 1)
            }
            .padding(.horizontal, 12)
            Spacer()
        }
        .allowsHitTesting(false)
    }
}

private struct CountdownOverlay: View {
    let value: Int

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)

            Text("\(value)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .scaleEffect(value == 3 ? 1.2 : value == 2 ? 1.1 : 1.0)
        }
        .transition(.opacity)
    }
}

private struct SectionDivider: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 4, height: 4)
            }
        }
        .padding(.vertical, 16)
    }
}

private struct StatusBar: View {
    let scrollEngine: ScrollEngine
    let sectionCount: Int

    var body: some View {
        if scrollEngine.isScrolling || sectionCount > 1 {
            HStack(spacing: 8) {
                if scrollEngine.isScrolling {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.red)
                            .frame(width: 6, height: 6)
                        Text(String(format: "%.1fx", scrollEngine.speed))
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }

                if sectionCount > 1 {
                    Spacer()
                    Text("\(scrollEngine.currentSectionIndex + 1)/\(sectionCount)")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 6)
            .transition(.opacity)
        }
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
