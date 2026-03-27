import Foundation
import Combine

@Observable
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
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.currentOffset += self.speed
        }
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

    deinit {
        timer?.invalidate()
    }
}
