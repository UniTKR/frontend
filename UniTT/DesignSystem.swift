//
//  DesignSystem.swift
//  UniTT
//
//  Created by Codex on 5/15/26.
//

import SwiftUI

enum UniTTColor {
    enum Brand {
        static let primary = Color("brand.primary")
        static let primaryHover = Color("brand.primaryHover")
        static let primaryPressed = Color("brand.primaryPressed")
        static let primarySubtle = Color("brand.primarySubtle")
        static let border = Color("brand.border")
        static let onPrimary = Color("brand.onPrimary")
    }

    enum Text {
        static let primary = Color("text.primary")
        static let secondary = Color("text.secondary")
        static let tertiary = Color("text.tertiary")
        static let disabled = Color("text.disabled")
        static let onBrand = Color("text.onBrand")
        static let link = Color("text.link")
    }

    enum Background {
        static let page = Color("background.page")
        static let surface = Color("background.surface")
        static let elevated = Color("background.elevated")
        static let subtle = Color("background.subtle")
        static let canvas = Color("background.canvas")
    }

    enum Border {
        static let subtle = Color("border.subtle")
        static let `default` = Color("border.default")
        static let strong = Color("border.strong")
        static let focus = Color("border.focus")
    }

    enum State {
        static let success = Color("state.success")
        static let successText = Color("state.successText")
        static let successBg = Color("state.successBg")
        static let warning = Color("state.warning")
        static let warningText = Color("state.warningText")
        static let warningBg = Color("state.warningBg")
        static let danger = Color("state.danger")
        static let dangerText = Color("state.dangerText")
        static let dangerBg = Color("state.dangerBg")
        static let neutral = Color("state.neutral")
    }

    enum Chip {
        enum Listed {
            static let bg = Color("chip.listed.bg")
            static let ink = Color("chip.listed.ink")
        }

        enum Reserved {
            static let bg = Color("chip.reserved.bg")
            static let ink = Color("chip.reserved.ink")
        }

        enum Completed {
            static let bg = Color("chip.completed.bg")
            static let ink = Color("chip.completed.ink")
        }

        enum Canceled {
            static let bg = Color("chip.canceled.bg")
            static let ink = Color("chip.canceled.ink")
        }

        enum Disputed {
            static let bg = Color("chip.disputed.bg")
            static let ink = Color("chip.disputed.ink")
        }
    }
}

enum UniTTSpacing {
    static let x2: CGFloat = 2
    static let x4: CGFloat = 4
    static let x6: CGFloat = 6
    static let x8: CGFloat = 8
    static let x10: CGFloat = 10
    static let x12: CGFloat = 12
    static let x16: CGFloat = 16
    static let x20: CGFloat = 20
    static let x24: CGFloat = 24
    static let x28: CGFloat = 28
    static let x32: CGFloat = 32
    static let x40: CGFloat = 40
    static let x48: CGFloat = 48
    static let x56: CGFloat = 56
    static let x64: CGFloat = 64

    enum Inset {
        static let compact: CGFloat = UniTTSpacing.x8
        static let cozy: CGFloat = UniTTSpacing.x12
        static let comfortable: CGFloat = UniTTSpacing.x16
        static let spacious: CGFloat = UniTTSpacing.x20
        static let loose: CGFloat = UniTTSpacing.x24
    }

    enum Stack {
        static let tight: CGFloat = UniTTSpacing.x4
        static let snug: CGFloat = UniTTSpacing.x8
        static let normal: CGFloat = UniTTSpacing.x12
        static let relaxed: CGFloat = UniTTSpacing.x16
        static let loose: CGFloat = UniTTSpacing.x24
        static let spacious: CGFloat = UniTTSpacing.x32
    }

    enum Inline {
        static let tight: CGFloat = UniTTSpacing.x4
        static let snug: CGFloat = UniTTSpacing.x8
        static let normal: CGFloat = UniTTSpacing.x12
        static let relaxed: CGFloat = UniTTSpacing.x16
    }

    enum Gutter {
        static let page: CGFloat = UniTTSpacing.x16
    }
}

enum UniTTRadius {
    static let sm: CGFloat = 6
    static let md: CGFloat = 8
    static let lg: CGFloat = 10
    static let xl: CGFloat = 12
    static let pill: CGFloat = 999
}

enum UniTTSize {
    static let touchMinimum: CGFloat = 44
    static let inputHeight: CGFloat = 40
    static let navbarHeight: CGFloat = 44
    static let ctaHeight: CGFloat = 48
    static let tabbarHeight: CGFloat = 49
    static let avatarXL: CGFloat = 80
}

enum UniTTTypography {
    static let displayMedium = Font.system(size: 28, weight: .bold)
    static let heading1 = Font.system(size: 22, weight: .semibold)
    static let heading2 = Font.system(size: 20, weight: .semibold)
    static let heading3 = Font.system(size: 17, weight: .semibold)
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 13, weight: .regular)
    static let labelLarge = Font.system(size: 15, weight: .medium)
    static let labelMedium = Font.system(size: 14, weight: .medium)
    static let labelSmall = Font.system(size: 12, weight: .medium)
    static let numeric = Font.system(size: 15, weight: .semibold, design: .monospaced)
    static let otp = Font.system(size: 28, weight: .bold, design: .monospaced)
}

extension Color {
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension View {
    func primaryCard() -> some View {
        self
            .background(UniTTColor.Background.elevated)
            .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
                    .stroke(UniTTColor.Border.default, lineWidth: 1)
            )
    }
}
