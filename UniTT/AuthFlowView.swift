//
//  AuthFlowView.swift
//  UniTT
//
//  Created by Codex on 5/20/26.
//

import Combine
import Foundation
import SwiftUI
import UIKit

enum AuthRoute {
    case splash
    case login
    case forgotEmail
    case forgotCode
    case resetPassword
    case signup
    case home
}

final class AuthViewModel: ObservableObject {
    @Published var route: AuthRoute = .splash
    @Published var loginEmail = "student.id@snu.ac.kr"
    @Published var loginPassword = "Unit1234!"
    @Published var resetEmail = "student.id@snu.ac.kr"
    @Published var resetDigits = ["4", "2", "9", "", "", ""]
    @Published var newPassword = "Unit1234!"
    @Published var newPasswordConfirmation = "Unit1234!"

    var canLogin: Bool {
        loginEmail.contains("@") && !loginPassword.isEmpty
    }

    var canRequestResetCode: Bool {
        resetEmail.contains("@") && resetEmail.contains(".")
    }

    var resetCode: String {
        resetDigits.joined()
    }

    var canVerifyResetCode: Bool {
        resetCode.count == 6 && resetDigits.allSatisfy { $0.count == 1 }
    }

    var passwordRules: [PasswordRule] {
        [
            PasswordRule(title: "8자 이상", satisfied: newPassword.count >= 8),
            PasswordRule(title: "영문 포함", satisfied: newPassword.rangeOfCharacter(from: .letters) != nil),
            PasswordRule(title: "숫자 포함", satisfied: newPassword.rangeOfCharacter(from: .decimalDigits) != nil),
            PasswordRule(title: "특수문자 포함", satisfied: newPassword.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil)
        ]
    }

    var canResetPassword: Bool {
        passwordRules.allSatisfy { $0.satisfied } &&
        !newPasswordConfirmation.isEmpty &&
        newPassword == newPasswordConfirmation
    }

    func finishSplash() {
        guard route == .splash else { return }
        route = .login
    }

    func login() {
        guard canLogin else { return }
        route = .home
    }

    func requestResetCode() {
        guard canRequestResetCode else { return }
        route = .forgotCode
    }

    func appendResetDigit(_ digit: String) {
        guard digit.count == 1, digit.allSatisfy(\.isNumber) else { return }
        guard let index = resetDigits.firstIndex(where: { $0.isEmpty }) else { return }
        resetDigits[index] = digit

        if canVerifyResetCode {
            route = .resetPassword
        }
    }

    func removeResetDigit() {
        guard let index = resetDigits.lastIndex(where: { !$0.isEmpty }) else { return }
        resetDigits[index] = ""
    }

    func resetPasswordAndReturnToLogin() {
        guard canResetPassword else { return }
        loginEmail = resetEmail
        loginPassword = newPassword
        route = .login
    }
}

struct AuthFlowView<AppContent: View>: View {
    @StateObject private var viewModel = AuthViewModel()
    let appContent: () -> AppContent

    init(@ViewBuilder appContent: @escaping () -> AppContent) {
        self.appContent = appContent
    }

    var body: some View {
        switch viewModel.route {
        case .splash:
            SplashScreen {
                viewModel.finishSplash()
            }
        case .login:
            LoginScreen(viewModel: viewModel)
        case .forgotEmail:
            ForgotEmailScreen(viewModel: viewModel)
        case .forgotCode:
            ForgotCodeScreen(viewModel: viewModel)
        case .resetPassword:
            ResetPasswordScreen(viewModel: viewModel)
        case .signup:
            OnboardingFlowView {
                viewModel.route = .home
            }
        case .home:
            appContent()
        }
    }
}

private struct SplashScreen: View {
    let onFinished: () -> Void

    var body: some View {
        ZStack {
            UniTTColor.Background.page.ignoresSafeArea()

            VStack(spacing: UniTTSpacing.Stack.relaxed) {
                Image("UniTTGlyph")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .accessibilityHidden(true)

                Image("UniTTWordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 44)
                    .accessibilityLabel("UniTT")

                Text("학교 인증된 학생들의 캠퍼스 마켓")
                    .font(UniTTTypography.bodyMedium)
                    .foregroundStyle(UniTTColor.Text.secondary)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 700_000_000)
            await MainActor.run {
                onFinished()
            }
        }
        .accessibilityIdentifier("splash-screen")
    }
}

private struct LoginScreen: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var showsPassword = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.normal) {
                    Image("UniTTWordmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 136, height: 40, alignment: .leading)
                        .accessibilityLabel("UniTT")

                    Text("학교 인증된 학생들의\n캠퍼스 마켓")
                        .font(UniTTTypography.displayMedium)
                        .foregroundStyle(UniTTColor.Text.primary)
                        .lineSpacing(2)

                    Text("학교 이메일로 안전하게 로그인하고 같은 학교 학생들과 거래해요.")
                        .font(UniTTTypography.bodyMedium)
                        .foregroundStyle(UniTTColor.Text.secondary)
                        .lineSpacing(4)
                }
                .padding(.top, UniTTSpacing.x64)

                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
                    HifiField(
                        title: "학교 이메일",
                        text: $viewModel.loginEmail,
                        placeholder: "student.id@snu.ac.kr",
                        keyboardType: .emailAddress,
                        accessibilityID: "login-email-field"
                    )

                    HifiPasswordField(
                        title: "비밀번호",
                        text: $viewModel.loginPassword,
                        showsText: $showsPassword,
                        accessibilityID: "login-password-field"
                    )

                    Button("로그인") {
                        viewModel.login()
                    }
                    .buttonStyle(HifiPrimaryButtonStyle(enabled: viewModel.canLogin))
                    .disabled(!viewModel.canLogin)
                    .accessibilityIdentifier("login-button")
                }

                HStack {
                    Button("비밀번호 찾기") {
                        viewModel.route = .forgotEmail
                    }
                    .font(UniTTTypography.labelMedium)
                    .foregroundStyle(UniTTColor.Brand.primary)
                    .accessibilityIdentifier("forgot-password-button")

                    Spacer()

                    Button("회원가입") {
                        viewModel.route = .signup
                    }
                    .font(UniTTTypography.labelMedium)
                    .foregroundStyle(UniTTColor.Brand.primary)
                    .accessibilityIdentifier("signup-button")
                }

                VStack(spacing: UniTTSpacing.Stack.snug) {
                    HifiDividerText("또는")

                    Button {
                    } label: {
                        SocialLoginLabel(title: "Apple로 계속하기", systemImage: "apple.logo")
                    }
                    .buttonStyle(HifiSecondaryButtonStyle())

                    Button {
                    } label: {
                        SocialLoginLabel(title: "Kakao로 계속하기", systemImage: "message.fill")
                    }
                    .buttonStyle(HifiSecondaryButtonStyle())
                }
                .padding(.top, UniTTSpacing.Stack.normal)
            }
            .padding(.horizontal, UniTTSpacing.Gutter.page)
            .padding(.bottom, UniTTSpacing.x40)
        }
        .background(UniTTColor.Background.page)
        .accessibilityIdentifier("login-screen")
    }
}

private struct ForgotEmailScreen: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        AuthScaffold(title: "비밀번호 찾기", backAction: { viewModel.route = .login }) {
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                HeaderTitle(
                    title: "가입한 학교 이메일을\n입력해 주세요",
                    subtitle: "입력한 이메일로 비밀번호 재설정 코드를 보내드릴게요."
                )

                HifiField(
                    title: "학교 이메일",
                    text: $viewModel.resetEmail,
                    placeholder: "student.id@snu.ac.kr",
                    keyboardType: .emailAddress,
                    accessibilityID: "forgot-email-field"
                )

                HifiNotice(
                    title: "학교 도메인은 가입 시 학교 기준으로 확인돼요.",
                    systemImage: "envelope.badge.shield.half.filled"
                )

                Spacer(minLength: UniTTSpacing.x32)

                Button("인증 코드 받기") {
                    viewModel.requestResetCode()
                }
                .buttonStyle(HifiPrimaryButtonStyle(enabled: viewModel.canRequestResetCode))
                .disabled(!viewModel.canRequestResetCode)
                .accessibilityIdentifier("forgot-email-next")
            }
        }
        .accessibilityIdentifier("forgot-email-screen")
    }
}

private struct ForgotCodeScreen: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        AuthScaffold(title: "코드 인증", backAction: { viewModel.route = .forgotEmail }) {
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                HeaderTitle(
                    title: "인증 코드 6자리를\n입력해 주세요",
                    subtitle: "\(viewModel.resetEmail)로 보낸 코드를 확인해 주세요."
                )

                AuthOTPCells(digits: viewModel.resetDigits)

                HStack {
                    Text("남은 시간 02:58")
                        .font(UniTTTypography.bodySmall)
                        .foregroundStyle(UniTTColor.State.danger)
                    Spacer()
                    Text("재전송")
                        .font(UniTTTypography.bodySmall.weight(.semibold))
                        .foregroundStyle(UniTTColor.Brand.primary)
                }

                HifiNotice(
                    title: "5회 이상 실패하면 5분 동안 재시도가 제한돼요.",
                    systemImage: "lock.shield"
                )

                Spacer(minLength: UniTTSpacing.x24)

                AuthNumberPad(
                    digitAction: viewModel.appendResetDigit,
                    deleteAction: viewModel.removeResetDigit
                )
            }
        }
        .accessibilityIdentifier("forgot-code-screen")
    }
}

private struct ResetPasswordScreen: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var showsPassword = false
    @State private var showsConfirmation = false

    var body: some View {
        AuthScaffold(title: "새 비밀번호", backAction: { viewModel.route = .forgotCode }) {
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                HeaderTitle(
                    title: "새 비밀번호를\n설정해 주세요",
                    subtitle: "설정이 끝나면 로그인 화면으로 돌아가요."
                )

                HifiPasswordField(
                    title: "새 비밀번호",
                    text: $viewModel.newPassword,
                    showsText: $showsPassword,
                    accessibilityID: "reset-password-field"
                )

                HifiPasswordField(
                    title: "새 비밀번호 확인",
                    text: $viewModel.newPasswordConfirmation,
                    showsText: $showsConfirmation,
                    accessibilityID: "reset-password-confirmation-field"
                )

                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.snug) {
                    ForEach(viewModel.passwordRules, id: \.title) { rule in
                        HifiRuleRow(title: rule.title, satisfied: rule.satisfied)
                    }
                    HifiRuleRow(
                        title: "두 비밀번호 일치",
                        satisfied: viewModel.newPassword == viewModel.newPasswordConfirmation
                    )
                }
                .padding(UniTTSpacing.Inset.cozy)
                .background(UniTTColor.Background.surface)
                .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))

                Spacer(minLength: UniTTSpacing.x32)

                Button("비밀번호 변경") {
                    viewModel.resetPasswordAndReturnToLogin()
                }
                .buttonStyle(HifiPrimaryButtonStyle(enabled: viewModel.canResetPassword))
                .disabled(!viewModel.canResetPassword)
                .accessibilityIdentifier("reset-password-submit")
            }
        }
        .accessibilityIdentifier("reset-password-screen")
    }
}

private struct AuthScaffold<Content: View>: View {
    let title: String
    let backAction: () -> Void
    let content: Content

    init(title: String, backAction: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.title = title
        self.backAction = backAction
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: backAction) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: UniTTSize.touchMinimum, height: UniTTSize.touchMinimum)
                }
                .foregroundStyle(UniTTColor.Text.primary)
                .accessibilityIdentifier("auth-back-button")

                Spacer()

                Text(title)
                    .font(UniTTTypography.heading3)
                    .foregroundStyle(UniTTColor.Text.primary)

                Spacer()

                Color.clear.frame(width: UniTTSize.touchMinimum, height: UniTTSize.touchMinimum)
            }
            .padding(.horizontal, UniTTSpacing.x6)
            .background(UniTTColor.Background.elevated)
            .overlay(alignment: .bottom) {
                Rectangle().fill(UniTTColor.Border.default).frame(height: 1)
            }

            content
                .padding(UniTTSpacing.Gutter.page)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(UniTTColor.Background.page)
    }
}

private struct HeaderTitle: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.snug) {
            Text(title)
                .font(UniTTTypography.displayMedium)
                .foregroundStyle(UniTTColor.Text.primary)
                .lineSpacing(2)
            Text(subtitle)
                .font(UniTTTypography.bodyMedium)
                .foregroundStyle(UniTTColor.Text.secondary)
                .lineSpacing(4)
        }
    }
}

private struct HifiField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let accessibilityID: String

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
            Text(title)
                .font(UniTTTypography.labelSmall)
                .foregroundStyle(UniTTColor.Text.secondary)

            TextField(placeholder, text: $text)
                .font(UniTTTypography.bodyMedium)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .inputChrome(focused: true)
                .accessibilityIdentifier(accessibilityID)
        }
    }
}

private struct HifiPasswordField: View {
    let title: String
    @Binding var text: String
    @Binding var showsText: Bool
    let accessibilityID: String

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
            Text(title)
                .font(UniTTTypography.labelSmall)
                .foregroundStyle(UniTTColor.Text.secondary)

            HStack(spacing: UniTTSpacing.Inline.snug) {
                Group {
                    if showsText {
                        TextField(title, text: $text)
                    } else {
                        SecureField(title, text: $text)
                    }
                }
                .font(UniTTTypography.bodyMedium)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier(accessibilityID)

                Button {
                    showsText.toggle()
                } label: {
                    Image(systemName: showsText ? "eye.slash" : "eye")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(UniTTColor.Text.secondary)
                }
                .buttonStyle(.plain)
            }
            .inputChrome(focused: true)
        }
    }
}

private struct HifiNotice: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: UniTTSpacing.Inline.snug) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(UniTTColor.Brand.primary)
                .accessibilityHidden(true)
            Text(title)
                .font(UniTTTypography.bodySmall)
                .foregroundStyle(UniTTColor.Text.secondary)
                .lineSpacing(3)
        }
        .padding(UniTTSpacing.Inset.cozy)
        .background(UniTTColor.Brand.primarySubtle)
        .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
    }
}

private struct HifiRuleRow: View {
    let title: String
    let satisfied: Bool

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.snug) {
            Image(systemName: satisfied ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(satisfied ? UniTTColor.State.success : UniTTColor.Text.tertiary)
                .accessibilityHidden(true)
            Text(title)
                .font(UniTTTypography.labelSmall)
                .foregroundStyle(satisfied ? UniTTColor.State.successText : UniTTColor.Text.secondary)
        }
    }
}

private struct AuthOTPCells: View {
    let digits: [String]

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.snug) {
            ForEach(Array(digits.enumerated()), id: \.offset) { index, digit in
                Text(digit)
                    .font(UniTTTypography.otp)
                    .foregroundStyle(UniTTColor.Text.primary)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(UniTTColor.Background.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
                            .stroke(index == activeIndex ? UniTTColor.Border.focus : UniTTColor.Border.default, lineWidth: 1)
                    )
            }
        }
    }

    private var activeIndex: Int {
        digits.firstIndex(where: { $0.isEmpty }) ?? max(digits.count - 1, 0)
    }
}

private struct AuthNumberPad: View {
    let digitAction: (String) -> Void
    let deleteAction: () -> Void

    private let rows = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", "delete"]
    ]

    var body: some View {
        VStack(spacing: UniTTSpacing.Stack.snug) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: UniTTSpacing.Inline.snug) {
                    ForEach(row, id: \.self) { value in
                        Button {
                            if value == "delete" {
                                deleteAction()
                            } else if !value.isEmpty {
                                digitAction(value)
                            }
                        } label: {
                            if value == "delete" {
                                Image(systemName: "delete.left")
                                    .font(.system(size: 18, weight: .medium))
                            } else {
                                Text(value)
                                    .font(UniTTTypography.heading2)
                            }
                        }
                        .foregroundStyle(UniTTColor.Text.primary)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(value.isEmpty ? Color.clear : UniTTColor.Background.surface)
                        .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
                        .disabled(value.isEmpty)
                        .accessibilityIdentifier(value == "delete" ? "forgot-keypad-delete" : "forgot-keypad-digit-\(value)")
                    }
                }
            }
        }
    }
}

private struct SocialLoginLabel: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .accessibilityHidden(true)
            Text(title)
        }
    }
}

private struct HifiDividerText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.normal) {
            Rectangle().fill(UniTTColor.Border.default).frame(height: 1)
            Text(text)
                .font(UniTTTypography.labelSmall)
                .foregroundStyle(UniTTColor.Text.tertiary)
            Rectangle().fill(UniTTColor.Border.default).frame(height: 1)
        }
    }
}

struct HifiPrimaryButtonStyle: ButtonStyle {
    let enabled: Bool

    init(enabled: Bool = true) {
        self.enabled = enabled
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(UniTTTypography.labelLarge)
            .foregroundStyle(enabled ? UniTTColor.Text.onBrand : UniTTColor.Text.disabled)
            .frame(maxWidth: .infinity, minHeight: UniTTSize.ctaHeight)
            .background(enabled ? (configuration.isPressed ? UniTTColor.Brand.primaryPressed : UniTTColor.Brand.primary) : UniTTColor.Background.subtle)
            .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous))
    }
}

struct HifiSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(UniTTTypography.labelLarge)
            .foregroundStyle(UniTTColor.Text.primary)
            .frame(maxWidth: .infinity, minHeight: UniTTSize.ctaHeight)
            .background(configuration.isPressed ? UniTTColor.Background.subtle : UniTTColor.Background.elevated)
            .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous)
                    .stroke(UniTTColor.Border.default, lineWidth: 1)
            )
    }
}
