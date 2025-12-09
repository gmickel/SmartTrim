import SwiftUI
import AppKit
import ServiceManagement
import Carbon.HIToolbox

@MainActor
@Observable
final class AppModel {
    var isAutoTrimEnabled = false {
        didSet {
            UserDefaults.standard.set(isAutoTrimEnabled, forKey: "isAutoTrimEnabled")
            if isAutoTrimEnabled {
                clipboardMonitor.startMonitoring()
            } else {
                clipboardMonitor.stopMonitoring()
            }
        }
    }

    var hotkeyKeyCode: UInt32 = 47
    var hotkeyModifiers: UInt32 = UInt32(cmdKey | shiftKey)

    private let healer = TextHealer()
    private let clipboardMonitor: ClipboardMonitor
    private var hotkeyManager: HotkeyManager?

    var launchAtLoginEnabled = false {
        didSet {
            guard launchAtLoginEnabled != oldValue else { return }
            do {
                if launchAtLoginEnabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update login item: \(error)")
                // Revert on failure
                launchAtLoginEnabled = oldValue
            }
        }
    }

    init() {
        clipboardMonitor = ClipboardMonitor(healer: healer)
        launchAtLoginEnabled = SMAppService.mainApp.status == .enabled
        isAutoTrimEnabled = UserDefaults.standard.bool(forKey: "isAutoTrimEnabled")

        if let savedKeyCode = UserDefaults.standard.object(forKey: "hotkeyKeyCode") as? UInt32 {
            hotkeyKeyCode = savedKeyCode
        }
        if let savedModifiers = UserDefaults.standard.object(forKey: "hotkeyModifiers") as? UInt32 {
            hotkeyModifiers = savedModifiers
        }

        setupHotkey()

        if isAutoTrimEnabled {
            clipboardMonitor.startMonitoring()
        }
    }

    func trimClipboardNow() {
        guard let content = NSPasteboard.general.string(forType: .string) else { return }
        let healed = healer.heal(content)
        if healed != content {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(healed, forType: .string)
        }
    }

    func updateHotkey(keyCode: UInt32, modifiers: UInt32) {
        hotkeyKeyCode = keyCode
        hotkeyModifiers = modifiers
        UserDefaults.standard.set(keyCode, forKey: "hotkeyKeyCode")
        UserDefaults.standard.set(modifiers, forKey: "hotkeyModifiers")
        setupHotkey()
    }

    private func setupHotkey() {
        hotkeyManager = HotkeyManager(keyCode: hotkeyKeyCode, modifiers: hotkeyModifiers) { [weak self] in
            Task { @MainActor in
                self?.trimClipboardNow()
            }
        }
    }
}
