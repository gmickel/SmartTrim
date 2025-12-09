import SwiftUI

// MARK: - Appearance Detection

@MainActor
@Observable
final class AppearanceObserver {
    static let shared = AppearanceObserver()

    var isDark: Bool

    private init() {
        isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua

        DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            }
        }
    }
}

// MARK: - Design Tokens

enum Design {
    // Typography
    static let fontDisplay = Font.system(size: 15, weight: .semibold, design: .rounded)
    static let fontHeadline = Font.system(size: 13, weight: .semibold, design: .rounded)
    static let fontBody = Font.system(size: 12, weight: .medium, design: .rounded)
    static let fontCaption = Font.system(size: 11, weight: .medium, design: .rounded)
    static let fontMono = Font.system(size: 11, weight: .medium, design: .monospaced)
    static let fontMonoSmall = Font.system(size: 10, weight: .medium, design: .monospaced)

    // Spacing
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 24

    // Radii
    static let radiusSM: CGFloat = 6
    static let radiusMD: CGFloat = 10
    static let radiusLG: CGFloat = 14
    static let radiusXL: CGFloat = 20
}

// MARK: - Color Helpers

struct Colors {
    let isDark: Bool

    // Backgrounds
    var background: Color {
        isDark
            ? Color(red: 0.11, green: 0.11, blue: 0.13)
            : Color(red: 0.97, green: 0.97, blue: 0.96)
    }

    var backgroundSecondary: Color {
        isDark
            ? Color(red: 0.14, green: 0.14, blue: 0.16)
            : Color(red: 0.93, green: 0.92, blue: 0.91)
    }

    var card: Color {
        isDark
            ? Color(red: 0.16, green: 0.16, blue: 0.18)
            : Color.white
    }

    var cardHover: Color {
        isDark
            ? Color(red: 0.19, green: 0.19, blue: 0.21)
            : Color(red: 0.98, green: 0.98, blue: 0.97)
    }

    // Accent (Warm Amber/Gold)
    var accent: Color {
        isDark
            ? Color(red: 0.96, green: 0.72, blue: 0.30)
            : Color(red: 0.80, green: 0.52, blue: 0.10)
    }

    var accentMuted: Color {
        isDark
            ? Color(red: 0.96, green: 0.72, blue: 0.30).opacity(0.15)
            : Color(red: 0.80, green: 0.52, blue: 0.10).opacity(0.12)
    }

    var accentVibrant: Color {
        Color(red: 0.98, green: 0.60, blue: 0.18)
    }

    // Text
    var textPrimary: Color {
        isDark
            ? Color(red: 0.95, green: 0.95, blue: 0.94)
            : Color(red: 0.10, green: 0.10, blue: 0.12)
    }

    var textSecondary: Color {
        isDark
            ? Color(red: 0.62, green: 0.62, blue: 0.60)
            : Color(red: 0.42, green: 0.42, blue: 0.40)
    }

    var textTertiary: Color {
        isDark
            ? Color(red: 0.42, green: 0.42, blue: 0.40)
            : Color(red: 0.62, green: 0.62, blue: 0.60)
    }

    // Borders
    var border: Color {
        isDark
            ? Color.white.opacity(0.08)
            : Color.black.opacity(0.08)
    }

    var borderStrong: Color {
        isDark
            ? Color.white.opacity(0.14)
            : Color.black.opacity(0.12)
    }

    // Semantic
    var success: Color {
        Color(red: 0.25, green: 0.72, blue: 0.48)
    }

    var danger: Color {
        isDark
            ? Color(red: 0.95, green: 0.42, blue: 0.42)
            : Color(red: 0.82, green: 0.28, blue: 0.28)
    }

    // Shadows
    var shadow: Color {
        isDark
            ? Color.black.opacity(0.5)
            : Color.black.opacity(0.10)
    }
}

// MARK: - Reusable Components

struct AppIcon: View {
    var size: CGFloat = 36

    private var colors: Colors { Colors(isDark: AppearanceObserver.shared.isDark) }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [colors.accent, colors.accentVibrant],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            Image(systemName: "scissors")
                .font(.system(size: size * 0.38, weight: .bold))
                .foregroundStyle(.white)
                .rotationEffect(.degrees(-45))
                .offset(x: 1, y: 1)
        }
        .shadow(color: colors.accent.opacity(0.35), radius: 8, x: 0, y: 4)
    }
}

struct StatusPill: View {
    let isActive: Bool
    let activeText: String
    let inactiveText: String

    private var colors: Colors { Colors(isDark: AppearanceObserver.shared.isDark) }

    var body: some View {
        HStack(spacing: Design.spacingXS) {
            Circle()
                .fill(isActive ? colors.success : colors.textTertiary)
                .frame(width: 6, height: 6)

            Text(isActive ? activeText : inactiveText)
                .font(Design.fontCaption)
                .foregroundStyle(isActive ? colors.success : colors.textTertiary)
        }
        .padding(.horizontal, Design.spacingSM)
        .padding(.vertical, Design.spacingXS)
        .background(
            Capsule()
                .fill(isActive ? colors.success.opacity(0.14) : colors.backgroundSecondary)
        )
        .animation(.spring(response: 0.3), value: isActive)
    }
}

struct CardButton<Content: View>: View {
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var isHovering = false
    @State private var isPressed = false

    private var colors: Colors { Colors(isDark: AppearanceObserver.shared.isDark) }

    var body: some View {
        Button(action: action) {
            content()
                .padding(Design.spacingMD)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: Design.radiusMD, style: .continuous)
                        .fill(isHovering ? colors.cardHover : colors.card)
                        .shadow(color: colors.shadow, radius: isHovering ? 8 : 4, x: 0, y: isHovering ? 3 : 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Design.radiusMD, style: .continuous)
                        .strokeBorder(colors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .onHover { isHovering = $0 }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct ToggleCard: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    private var colors: Colors { Colors(isDark: AppearanceObserver.shared.isDark) }

    var body: some View {
        HStack(spacing: Design.spacingMD) {
            ZStack {
                RoundedRectangle(cornerRadius: Design.radiusSM, style: .continuous)
                    .fill(colors.accentMuted)
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(colors.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Design.fontBody)
                    .foregroundStyle(colors.textPrimary)

                Text(subtitle)
                    .font(Design.fontCaption)
                    .foregroundStyle(colors.textTertiary)
            }

            Spacer()

            CustomToggle(isOn: $isOn)
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
}

struct CustomToggle: View {
    @Binding var isOn: Bool

    private var colors: Colors { Colors(isDark: AppearanceObserver.shared.isDark) }

    var body: some View {
        ZStack {
            Capsule()
                .fill(isOn ? colors.accent : colors.backgroundSecondary)
                .frame(width: 44, height: 26)
                .overlay(
                    Capsule()
                        .strokeBorder(isOn ? colors.accent : colors.border, lineWidth: 1)
                )

            Circle()
                .fill(.white)
                .frame(width: 20, height: 20)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                .offset(x: isOn ? 9 : -9)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isOn.toggle()
            }
        }
    }
}

struct SectionLabel: View {
    let text: String

    private var colors: Colors { Colors(isDark: AppearanceObserver.shared.isDark) }

    var body: some View {
        Text(text.uppercased())
            .font(Design.fontMonoSmall)
            .foregroundStyle(colors.textTertiary)
            .tracking(1.2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct KeyboardKey: View {
    let label: String

    private var colors: Colors { Colors(isDark: AppearanceObserver.shared.isDark) }

    var body: some View {
        Text(label)
            .font(Design.fontMono)
            .foregroundStyle(colors.textPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(colors.backgroundSecondary)
                    .shadow(color: colors.shadow.opacity(0.5), radius: 1, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .strokeBorder(colors.borderStrong, lineWidth: 1)
            )
    }
}
