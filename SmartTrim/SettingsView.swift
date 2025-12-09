import SwiftUI
import Carbon.HIToolbox

struct SettingsView: View {
    @Bindable var model: AppModel
    @Environment(\.openURL) private var openURL

    @State private var selectedTab: SettingsTab = .general
    @State private var appearAnimation = false

    private var colors: Colors { Colors(isDark: AppearanceObserver.shared.isDark) }

    enum SettingsTab: String, CaseIterable {
        case general = "General"
        case hotkey = "Hotkey"
        case about = "About"

        var icon: String {
            switch self {
            case .general: "gearshape"
            case .hotkey: "command.square"
            case .about: "info.circle"
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
                .frame(width: 180)
                .background(colors.backgroundSecondary)

            ScrollView {
                Group {
                    switch selectedTab {
                    case .general: generalContent
                    case .hotkey: hotkeyContent
                    case .about: aboutContent
                    }
                }
                .padding(Design.spacingXL)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colors.background)
        }
        .frame(width: 560, height: 420)
        .clipShape(RoundedRectangle(cornerRadius: Design.radiusLG, style: .continuous))
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(spacing: 0) {
            VStack(spacing: Design.spacingSM) {
                AppIcon(size: 48)
                    .scaleEffect(appearAnimation ? 1 : 0.8)
                    .opacity(appearAnimation ? 1 : 0)

                Text("SmartTrim")
                    .font(Design.fontDisplay)
                    .foregroundStyle(colors.textPrimary)

                Text("v1.0.0")
                    .font(Design.fontMonoSmall)
                    .foregroundStyle(colors.textTertiary)
            }
            .padding(.vertical, Design.spacingXL)
            .frame(maxWidth: .infinity)

            Divider()
                .background(colors.border)
                .padding(.horizontal, Design.spacingLG)

            VStack(spacing: Design.spacingXS) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    sidebarButton(tab: tab)
                }
            }
            .padding(Design.spacingMD)

            Spacer()
        }
    }

    private func sidebarButton(tab: SettingsTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: Design.spacingSM) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 20)

                Text(tab.rawValue)
                    .font(Design.fontBody)

                Spacer()
            }
            .foregroundStyle(selectedTab == tab ? colors.accent : colors.textSecondary)
            .padding(.horizontal, Design.spacingMD)
            .padding(.vertical, Design.spacingSM)
            .background(
                RoundedRectangle(cornerRadius: Design.radiusSM, style: .continuous)
                    .fill(selectedTab == tab ? colors.accentMuted : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - General Content

    private var generalContent: some View {
        VStack(alignment: .leading, spacing: Design.spacingLG) {
            Text("General")
                .font(Design.fontDisplay)
                .foregroundStyle(colors.textPrimary)

            VStack(spacing: Design.spacingMD) {
                SectionLabel(text: "Startup")

                ToggleCard(
                    icon: "power",
                    title: "Launch at Login",
                    subtitle: "Start SmartTrim when you log in",
                    isOn: Binding(
                        get: { model.launchAtLoginEnabled },
                        set: { model.launchAtLoginEnabled = $0 }
                    )
                )
            }

            VStack(spacing: Design.spacingMD) {
                SectionLabel(text: "Behavior")

                ToggleCard(
                    icon: "wand.and.rays",
                    title: "Auto-Trim",
                    subtitle: "Automatically clean malformed clipboard text",
                    isOn: $model.isAutoTrimEnabled
                )
            }

            Spacer()
        }
    }

    // MARK: - Hotkey Content

    private var hotkeyContent: some View {
        VStack(alignment: .leading, spacing: Design.spacingLG) {
            Text("Hotkey")
                .font(Design.fontDisplay)
                .foregroundStyle(colors.textPrimary)

            VStack(alignment: .leading, spacing: Design.spacingMD) {
                SectionLabel(text: "Keyboard Shortcut")

                Text("Click below and press your desired key combination to set a global hotkey for manual clipboard trimming.")
                    .font(Design.fontCaption)
                    .foregroundStyle(colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HotkeyRecorderView(
                    keyCode: model.hotkeyKeyCode,
                    modifiers: model.hotkeyModifiers,
                    onRecorded: { keyCode, modifiers in
                        model.updateHotkey(keyCode: keyCode, modifiers: modifiers)
                    }
                )
            }

            Spacer()
        }
    }

    // MARK: - About Content

    private var aboutContent: some View {
        VStack(alignment: .leading, spacing: Design.spacingLG) {
            Text("About")
                .font(Design.fontDisplay)
                .foregroundStyle(colors.textPrimary)

            // App Card
            HStack(spacing: Design.spacingLG) {
                AppIcon(size: 72)

                VStack(alignment: .leading, spacing: Design.spacingXS) {
                    Text("SmartTrim")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(colors.textPrimary)

                    Text("Version 1.0.0")
                        .font(Design.fontMono)
                        .foregroundStyle(colors.textSecondary)

                    Text("Precision clipboard cleaning for macOS")
                        .font(Design.fontCaption)
                        .foregroundStyle(colors.textTertiary)
                        .padding(.top, 2)
                }

                Spacer()
            }
            .padding(Design.spacingLG)
            .background(
                RoundedRectangle(cornerRadius: Design.radiusMD, style: .continuous)
                    .fill(colors.card)
                    .shadow(color: colors.shadow, radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Design.radiusMD, style: .continuous)
                    .strokeBorder(colors.border, lineWidth: 1)
            )

            // Author Card
            VStack(alignment: .leading, spacing: Design.spacingMD) {
                SectionLabel(text: "Created By")

                HStack(spacing: Design.spacingMD) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [colors.accent.opacity(0.9), colors.accentVibrant],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)

                        Text("GM")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Gordon Mickel")
                            .font(Design.fontHeadline)
                            .foregroundStyle(colors.textPrimary)

                        Button {
                            if let url = URL(string: "https://mickel.tech") {
                                openURL(url)
                            }
                        } label: {
                            HStack(spacing: Design.spacingXS) {
                                Text("mickel.tech")
                                    .font(Design.fontCaption)
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundStyle(colors.accent)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()
                }
                .padding(Design.spacingMD)
                .background(
                    RoundedRectangle(cornerRadius: Design.radiusMD, style: .continuous)
                        .fill(colors.card)
                        .shadow(color: colors.shadow, radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Design.radiusMD, style: .continuous)
                        .strokeBorder(colors.border, lineWidth: 1)
                )
            }

            // Features
            VStack(alignment: .leading, spacing: Design.spacingMD) {
                SectionLabel(text: "Features")

                VStack(alignment: .leading, spacing: Design.spacingSM) {
                    featureItem(icon: "text.alignleft", text: "Removes ghost indentation")
                    featureItem(icon: "arrow.turn.down.right", text: "Fixes hard-wrapped lines")
                    featureItem(icon: "list.bullet", text: "Preserves list structure")
                    featureItem(icon: "paragraphsign", text: "Maintains paragraph breaks")
                }
                .padding(Design.spacingMD)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: Design.radiusMD, style: .continuous)
                        .fill(colors.card)
                        .shadow(color: colors.shadow, radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Design.radiusMD, style: .continuous)
                        .strokeBorder(colors.border, lineWidth: 1)
                )
            }

            Spacer()
        }
    }

    private func featureItem(icon: String, text: String) -> some View {
        HStack(spacing: Design.spacingSM) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(colors.accent)
                .frame(width: 20)

            Text(text)
                .font(Design.fontBody)
                .foregroundStyle(colors.textSecondary)
        }
    }
}

// MARK: - Hotkey Recorder

struct HotkeyRecorderView: View {
    let keyCode: UInt32
    let modifiers: UInt32
    let onRecorded: (UInt32, UInt32) -> Void

    @State private var isRecording = false
    @State private var isHovering = false

    private var colors: Colors { Colors(isDark: AppearanceObserver.shared.isDark) }

    var body: some View {
        Button {
            isRecording = true
        } label: {
            HStack(spacing: Design.spacingMD) {
                ZStack {
                    RoundedRectangle(cornerRadius: Design.radiusSM, style: .continuous)
                        .fill(isRecording ? colors.accent : colors.accentMuted)
                        .frame(width: 36, height: 36)

                    Image(systemName: "keyboard")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isRecording ? .white : colors.accent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Trim Clipboard")
                        .font(Design.fontBody)
                        .foregroundStyle(colors.textPrimary)

                    Text(isRecording ? "Press your shortcut..." : "Click to record")
                        .font(Design.fontCaption)
                        .foregroundStyle(isRecording ? colors.accent : colors.textTertiary)
                }

                Spacer()

                HStack(spacing: 4) {
                    ForEach(hotkeyParts, id: \.self) { part in
                        KeyboardKey(label: part)
                    }
                }
            }
            .padding(Design.spacingMD)
            .background(
                RoundedRectangle(cornerRadius: Design.radiusMD, style: .continuous)
                    .fill(isRecording ? colors.accentMuted.opacity(0.5) : (isHovering ? colors.cardHover : colors.card))
                    .shadow(color: colors.shadow, radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Design.radiusMD, style: .continuous)
                    .strokeBorder(isRecording ? colors.accent : colors.border, lineWidth: isRecording ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .background(
            HotkeyRecorderBackgroundView(isRecording: $isRecording, onRecorded: onRecorded)
        )
        .animation(.spring(response: 0.3), value: isRecording)
    }

    private var hotkeyParts: [String] {
        var parts: [String] = []
        if modifiers & UInt32(cmdKey) != 0 { parts.append("\u{2318}") }
        if modifiers & UInt32(shiftKey) != 0 { parts.append("\u{21E7}") }
        if modifiers & UInt32(optionKey) != 0 { parts.append("\u{2325}") }
        if modifiers & UInt32(controlKey) != 0 { parts.append("\u{2303}") }
        parts.append(keyCodeToString(keyCode))
        return parts
    }

    private func keyCodeToString(_ keyCode: UInt32) -> String {
        let keyMap: [UInt32: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
            30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 37: "L",
            38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",", 44: "/",
            45: "N", 46: "M", 47: ".", 50: "`"
        ]
        return keyMap[keyCode] ?? "?"
    }
}

// MARK: - NSView Representable

struct HotkeyRecorderBackgroundView: NSViewRepresentable {
    @Binding var isRecording: Bool
    let onRecorded: (UInt32, UInt32) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = HotkeyRecorderNSView()
        view.onKeyDown = { keyCode, modifiers in
            onRecorded(keyCode, modifiers)
            isRecording = false
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let view = nsView as? HotkeyRecorderNSView, isRecording {
            view.window?.makeFirstResponder(view)
        }
    }
}

final class HotkeyRecorderNSView: NSView {
    var onKeyDown: ((UInt32, UInt32) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func keyDown(with event: NSEvent) {
        let modifiers = carbonModifiersFromNSEvent(event)
        onKeyDown?(UInt32(event.keyCode), modifiers)
    }

    private func carbonModifiersFromNSEvent(_ event: NSEvent) -> UInt32 {
        var result: UInt32 = 0
        if event.modifierFlags.contains(.command) { result |= UInt32(cmdKey) }
        if event.modifierFlags.contains(.shift) { result |= UInt32(shiftKey) }
        if event.modifierFlags.contains(.option) { result |= UInt32(optionKey) }
        if event.modifierFlags.contains(.control) { result |= UInt32(controlKey) }
        return result
    }
}
