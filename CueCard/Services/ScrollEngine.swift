import Foundation

@Observable
@MainActor
final class ScrollEngine {
    var isScrolling = false
    var currentOffset: CGFloat = 0
    var speed: Double = 1.0
    var countdownValue: Int = 0
    var currentSectionIndex: Int = 0
    var sectionCount: Int = 1
    var sectionOffsets: [CGFloat] = [0]

    private var timer: Timer?
    private var countdownTimer: Timer?

    func toggle() {
        if isScrolling {
            pause()
        } else if countdownValue > 0 {
            cancelCountdown()
        } else {
            startCountdown()
        }
    }

    func startCountdown() {
        countdownValue = 3
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.countdownValue -= 1
                if self.countdownValue <= 0 {
                    self.countdownTimer?.invalidate()
                    self.countdownTimer = nil
                    self.start()
                }
            }
        }
    }

    func cancelCountdown() {
        countdownValue = 0
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    func start() {
        guard !isScrolling else { return }
        countdownValue = 0
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
        cancelCountdown()
        currentOffset = 0
        currentSectionIndex = 0
    }

    func nudge(by amount: CGFloat) {
        currentOffset += amount
        if currentOffset < 0 { currentOffset = 0 }
    }

    func jumpToSection(_ index: Int) {
        guard index >= 0, index < sectionOffsets.count else { return }
        currentSectionIndex = index
        currentOffset = sectionOffsets[index]
    }

    func nextSection() {
        jumpToSection(currentSectionIndex + 1)
    }

    func previousSection() {
        jumpToSection(currentSectionIndex - 1)
    }

    nonisolated func cleanup() {
        MainActor.assumeIsolated {
            timer?.invalidate()
            countdownTimer?.invalidate()
        }
    }
}
