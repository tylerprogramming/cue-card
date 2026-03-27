import Foundation

@Observable
@MainActor
final class ScrollEngine {
    var isScrolling = false
    var currentOffset: CGFloat = 0
    var speed: Double = 1.0

    private var timer: Timer?

    func toggle() {
        if isScrolling { pause() } else { start() }
    }

    func start() {
        guard !isScrolling else { return }
        isScrolling = true
        let t = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.currentOffset += self.speed
            }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func pause() {
        isScrolling = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        currentOffset = 0
    }

    func nudge(by amount: CGFloat) {
        currentOffset += amount
        if currentOffset < 0 { currentOffset = 0 }
    }

    nonisolated func cleanup() {
        MainActor.assumeIsolated {
            timer?.invalidate()
        }
    }
}
