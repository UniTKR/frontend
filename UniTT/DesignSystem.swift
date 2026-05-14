//
//  DesignSystem.swift
//  UniTT
//
//  Created by Codex on 5/15/26.
//

import SwiftUI

enum UniTTColor {
    enum Brand {
        static let primary = Color(hex: 0x4F46E5)
        static let primaryHover = Color(hex: 0x4338CA)
        static let primaryPressed = Color(hex: 0x3730A3)
        static let primarySubtle = Color(hex: 0xEEF2FF)
        static let border = Color(hex: 0xC7D2FE)
        static let onPrimary = Color.white
    }

    enum Text {
        static let primary = Color(hex: 0x0F172A)
        static let secondary = Color(hex: 0x475569)
        static let tertiary = Color(hex: 0x94A3B8)
        static let disabled = Color(hex: 0xCBD5E1)
        static let onBrand = Color.white
    }

    enum Background {
        static let page = Color.white
        static let surface = Color(hex: 0xF8FAFC)
        static let elevated = Color.white
        static let subtle = Color(hex: 0xF1F5F9)
    }

    enum Border {
        static let subtle = Color(hex: 0xEEF2F6)
        static let `default` = Color(hex: 0xE2E8F0)
        static let strong = Color(hex: 0xCBD5E1)
        static let focus = Brand.primary
    }

    enum State {
        static let success = Color(hex: 0x10B981)
        static let successText = Color(hex: 0x047857)
        static let warning = Color(hex: 0xF59E0B)
        static let warningText = Color(hex: 0xB45309)
        static let danger = Color(hex: 0xDC2626)
        static let neutral = Color(hex: 0x94A3B8)
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
