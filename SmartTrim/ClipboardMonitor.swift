import AppKit
import Foundation

@MainActor
final class ClipboardMonitor {
    private let healer: TextHealer
    private var timer: Timer?
    private var lastChangeCount: Int = 0

    init(healer: TextHealer) {
        self.healer = healer
        lastChangeCount = NSPasteboard.general.changeCount
    }

    func startMonitoring() {
        stopMonitoring()
        lastChangeCount = NSPasteboard.general.changeCount

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkClipboard()
            }
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount

        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        guard let content = pasteboard.string(forType: .string) else { return }
        guard healer.looksLikeMalformed(content) else { return }

        let healed = healer.heal(content)
        guard healed != content else { return }

        pasteboard.clearContents()
        pasteboard.setString(healed, forType: .string)
        lastChangeCount = pasteboard.changeCount
    }
}
