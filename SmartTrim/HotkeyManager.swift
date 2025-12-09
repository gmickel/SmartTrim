import Carbon.HIToolbox
import Foundation

@MainActor
final class HotkeyManager {
    private var hotkeyRef: EventHotKeyRef?
    private static var currentHandler: (@MainActor () -> Void)?

    init(keyCode: UInt32, modifiers: UInt32, handler: @escaping @MainActor () -> Void) {
        HotkeyManager.currentHandler = handler
        registerHotkey(keyCode: keyCode, modifiers: modifiers)
    }

    func unregister() {
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
            hotkeyRef = nil
        }
    }

    private func registerHotkey(keyCode: UInt32, modifiers: UInt32) {
        unregister()

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let handlerProc: EventHandlerUPP = { _, _, _ -> OSStatus in
            Task { @MainActor in
                HotkeyManager.currentHandler?()
            }
            return noErr
        }

        InstallEventHandler(GetApplicationEventTarget(), handlerProc, 1, &eventType, nil, nil)

        let hotkeyID = EventHotKeyID(signature: OSType(0x5354_524D), id: 1)
        let carbonModifiers = carbonModifiersFromCocoa(modifiers)

        RegisterEventHotKey(keyCode, carbonModifiers, hotkeyID, GetApplicationEventTarget(), 0, &hotkeyRef)
    }

    private func carbonModifiersFromCocoa(_ modifiers: UInt32) -> UInt32 {
        var result: UInt32 = 0
        if modifiers & UInt32(cmdKey) != 0 { result |= UInt32(cmdKey) }
        if modifiers & UInt32(shiftKey) != 0 { result |= UInt32(shiftKey) }
        if modifiers & UInt32(optionKey) != 0 { result |= UInt32(optionKey) }
        if modifiers & UInt32(controlKey) != 0 { result |= UInt32(controlKey) }
        return result
    }
}
