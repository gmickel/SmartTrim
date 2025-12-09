import SwiftUI

struct MenuView: View {
    @Bindable var model: AppModel
    @Environment(\.openWindow) private var openWindow

    @State private var trimPressed = false
    @State private var appearAnimation = false

    private var colors: Colors { Colors(isDark: AppearanceObserver.shared.isDark) }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, Design.spacingLG)
                .padding(.top, Design.spacingLG)
                .padding(.bottom, Design.spacingMD)

            Divider()
                .background(colors.border)
                .padding(.horizontal, Design.spacingLG)

            VStack(spacing: Design.spacingSM) {
                autoTrimCard
                trimNowCard
            }
            .padding(Design.spacingLG)

            Divider()
                .background(colors.border)
                .padding(.horizontal, Design.spacingLG)

            footer
                .padding(.horizontal, Design.spacingLG)
                .padding(.vertical, Design.spacingMD)
        }
        .frame(width: 280)
        .background(colors.background)
        .clipShape(RoundedRectangle(cornerRadius: Design.radiusLG, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Design.radiusLG, style: .continuous)
                .strokeBorder(colors.border, lineWidth: 1)
        )
        .shadow(color: colors.shadow, radius: 16, x: 0, y: 8)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: Design.spacingMD) {
            AppIcon(size: 40)
                .scaleEffect(appearAnimation ? 1 : 0.8)
                .opacity(appearAnimation ? 1 : 0)

            VStack(alignment: .leading, spacing: Design.spacingXS) {
                Text("SmartTrim")
                    .font(Design.fontDisplay)
                    .foregroundStyle(colors.textPrimary)

                StatusPill(
                    isActive: model.isAutoTrimEnabled,
                    activeText: "Active",
                    inactiveText: "Standby"
                )
            }

            Spacer()
        }
    }

    // MARK: - Auto-Trim Card

    private var autoTrimCard: some View {
        ToggleCard(
            icon: "wand.and.rays",
            title: "Auto-Trim",
            subtitle: "Clean clipboard automatically",
            isOn: $model.isAutoTrimEnabled
        )
        .offset(y: appearAnimation ? 0 : 10)
        .opacity(appearAnimation ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.05), value: appearAnimation)
    }

    // MARK: - Trim Now Card

    private var trimNowCard: some View {
        CardButton {
            withAnimation(.spring(response: 0.2)) {
                trimPressed = true
            }
            model.trimClipboardNow()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3)) {
                    trimPressed = false
                }
            }
        } content: {
            HStack(spacing: Design.spacingMD) {
                ZStack {
                    RoundedRectangle(cornerRadius: Design.radiusSM, style: .continuous)
                        .fill(trimPressed ? colors.accent : colors.accentMuted)
                        .frame(width: 32, height: 32)

                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(trimPressed ? .white : colors.accent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Trim Now")
                        .font(Design.fontBody)
                        .foregroundStyle(colors.textPrimary)

                    Text("Clean current clipboard")
                        .font(Design.fontCaption)
                        .foregroundStyle(colors.textTertiary)
                }

                Spacer()

                HStack(spacing: 3) {
                    KeyboardKey(label: "\u{2318}")
                    KeyboardKey(label: "\u{21E7}")
                    KeyboardKey(label: ".")
                }
            }
        }
        .offset(y: appearAnimation ? 0 : 10)
        .opacity(appearAnimation ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1), value: appearAnimation)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Button {
                openWindow(id: "settings")
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                HStack(spacing: Design.spacingXS) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12, weight: .medium))
                    Text("Settings")
                        .font(Design.fontCaption)
                }
                .foregroundStyle(colors.textSecondary)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                NSApp.terminate(nil)
            } label: {
                Text("Quit")
                    .font(Design.fontCaption)
                    .foregroundStyle(colors.danger)
            }
            .buttonStyle(.plain)
        }
        .offset(y: appearAnimation ? 0 : 5)
        .opacity(appearAnimation ? 1 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.15), value: appearAnimation)
    }
}
