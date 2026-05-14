//
//  OnboardingFlowView.swift
//  UniTT
//
//  Created by Codex on 5/15/26.
//

import Foundation
import PhotosUI
import SwiftUI
import UIKit

struct OnboardingFlowView: View {
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                UniTTColor.Background.page
                    .ignoresSafeArea()

                switch viewModel.step {
                case .school:
                    SchoolSelectionScreen(viewModel: viewModel)
                case .email:
                    EmailVerificationScreen(viewModel: viewModel)
                case .code:
                    OTPCodeScreen(viewModel: viewModel)
                case .terms:
                    TermsAgreementScreen(viewModel: viewModel)
                case .profile:
                    ProfileSetupScreen(viewModel: viewModel)
                case .completed:
                    OnboardingCompleteScreen()
                }
            }
        }
        .tint(UniTTColor.Brand.primary)
        .sheet(item: $viewModel.presentedTerm) { term in
            TermDetailSheet(term: term)
                .presentationDetents([.medium])
        }
    }
}

private struct SchoolSelectionScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingScreenScaffold(
            title: "학교 선택",
            step: .school,
            rightText: "건너뛰기",
            ctaTitle: "학교를 선택하세요",
            ctaEnabled: viewModel.canContinueFromSchool,
            ctaAction: viewModel.continueFromCurrentStep
        ) {
            StepIndicator(activeCount: OnboardingStep.school.progressCount)
                .padding(.bottom, UniTTSpacing.Stack.relaxed)

            HeaderCopy(
                title: "어느 학교에 다녀요?",
                subtitle: "학교 메일로 인증된 학생끼리만\n거래할 수 있어요."
            )

            SearchField(text: $viewModel.searchText, placeholder: "학교 이름을 검색해 보세요")
                .padding(.top, UniTTSpacing.Stack.loose)

            SectionLabel("인기 학교")
                .padding(.top, UniTTSpacing.Stack.relaxed)

            VStack(spacing: 0) {
                ForEach(viewModel.filteredUniversities) { university in
                    SchoolRow(
                        university: university,
                        selected: viewModel.selectedUniversity == university
                    ) {
                        viewModel.selectUniversity(university)
                    }
                }
            }
        }
        .accessibilityIdentifier("school-selection-screen")
    }
}

private struct EmailVerificationScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingScreenScaffold(
            title: "이메일 인증",
            step: .email,
            backAction: viewModel.goBack,
            ctaTitle: "인증 메일 보내기",
            ctaEnabled: viewModel.canSendVerificationEmail,
            ctaAction: viewModel.continueFromCurrentStep
        ) {
            StepIndicator(activeCount: OnboardingStep.email.progressCount)
                .padding(.bottom, UniTTSpacing.Stack.relaxed)

            HeaderCopy(
                title: "학교 이메일을\n입력해 주세요",
                subtitle: "\(viewModel.selectedUniversity?.name ?? "서울대학교") 학생만 가입할 수 있어요.\n이메일은 다른 사용자에게 공개되지 않아요."
            )

            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                FieldLabel("학교 이메일")
                HStack(spacing: UniTTSpacing.Inline.snug) {
                    TextField("student.id", text: $viewModel.emailLocalPart)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .font(UniTTTypography.bodyMedium)
                        .accessibilityIdentifier("email-local-part-field")

                    Text("@\(viewModel.selectedUniversity?.domain ?? "snu.ac.kr")")
                        .font(UniTTTypography.bodyMedium)
                        .foregroundStyle(UniTTColor.Text.secondary)
                }
                .inputChrome(focused: true)

                HelpText("재학생/대학원생 메일만 가능. 졸업생 메일은 인증되지 않아요.")
            }
            .padding(.top, UniTTSpacing.Stack.loose)

            InfoBox(
                title: "왜 학교 메일이 필요해요?",
                lines: [
                    "같은 학교 학생만 거래에 참여시켜",
                    "사기·노쇼 위험을 줄이고",
                    "캠퍼스 내 픽업을 안전하게 만들어요."
                ]
            )
            .padding(.top, UniTTSpacing.Stack.loose)
        }
        .accessibilityIdentifier("email-verification-screen")
    }
}

private struct OTPCodeScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingScreenScaffold(
            title: "이메일 인증",
            step: .code,
            backAction: viewModel.goBack,
            showsCTA: false
        ) {
            StepIndicator(activeCount: OnboardingStep.code.progressCount)
                .padding(.bottom, UniTTSpacing.Stack.relaxed)

            HeaderCopy(
                title: "인증 코드 6자리를\n입력해 주세요",
                subtitle: "\(viewModel.emailAddress)로 보냈어요.\n스팸함도 확인해 주세요."
            )

            OTPCells(digits: viewModel.otpDigits)
                .padding(.top, UniTTSpacing.Stack.loose)

            HStack {
                Text("남은 시간 02:47")
                    .foregroundStyle(UniTTColor.State.danger)
                Spacer()
                Button("코드 재전송") {}
                    .font(UniTTTypography.bodySmall)
                    .foregroundStyle(UniTTColor.Brand.primary)
                    .accessibilityIdentifier("resend-code-button")
            }
            .font(UniTTTypography.bodySmall)
            .padding(.top, UniTTSpacing.Stack.snug)

            InfoBox(
                title: "메일이 오지 않나요?",
                lines: [
                    "스팸/프로모션 폴더 확인",
                    "학교 메일 시스템 점검 중인지 확인",
                    "그래도 안 오면 고객센터 문의"
                ]
            )
            .padding(.top, UniTTSpacing.Stack.spacious)

            Spacer(minLength: UniTTSpacing.Stack.loose)

            NumericKeypad(
                digitAction: viewModel.appendOTPDigit,
                deleteAction: viewModel.removeLastOTPDigit
            )
        }
        .accessibilityIdentifier("otp-code-screen")
    }
}

private struct TermsAgreementScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        OnboardingScreenScaffold(
            title: "약관 동의",
            step: .terms,
            backAction: viewModel.goBack,
            ctaTitle: "동의하고 계속",
            ctaEnabled: viewModel.canContinueTerms,
            ctaAction: viewModel.continueFromCurrentStep
        ) {
            StepIndicator(activeCount: OnboardingStep.terms.progressCount)
                .padding(.bottom, UniTTSpacing.Stack.relaxed)

            HeaderCopy(
                title: "약관에 동의하고\n유니트를 시작해 볼까요?",
                subtitle: "필수 항목에 동의해야 가입할 수 있어요.\n선택 항목은 언제든 설정에서 변경할 수 있어요."
            )

            VStack(spacing: 0) {
                Button {
                    viewModel.setAllTermsAccepted(!viewModel.allTermsAccepted)
                } label: {
                    TermsRowContent(
                        checked: viewModel.allTermsAccepted,
                        title: "전체 동의 (선택 포함)",
                        tag: nil,
                        emphasized: true,
                        showsDisclosure: false
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("terms-toggle-all")

                Divider().background(UniTTColor.Text.primary)

                ForEach(TermAgreement.all) { term in
                    TermRow(
                        term: term,
                        checked: viewModel.acceptedTermIDs.contains(term.id),
                        toggleAction: {
                            viewModel.toggleTerm(term)
                        },
                        detailAction: {
                            viewModel.presentedTerm = term
                        }
                    )
                }
            }
            .padding(.top, UniTTSpacing.Stack.loose)
        }
        .accessibilityIdentifier("terms-agreement-screen")
    }
}

private struct ProfileSetupScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: Image?

    var body: some View {
        OnboardingScreenScaffold(
            title: "프로필 설정",
            step: .profile,
            backAction: viewModel.goBack,
            ctaTitle: "시작하기",
            ctaEnabled: viewModel.canFinishProfile,
            ctaAction: viewModel.continueFromCurrentStep
        ) {
            StepIndicator(activeCount: OnboardingStep.profile.progressCount)
                .padding(.bottom, UniTTSpacing.Stack.relaxed)

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                AvatarPickerLabel(image: avatarImage, hasProfilePhoto: viewModel.hasProfilePhoto)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .padding(.top, UniTTSpacing.Stack.snug)
            .padding(.bottom, UniTTSpacing.Stack.loose)
            .accessibilityIdentifier("profile-photo-picker")

            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                HStack(alignment: .lastTextBaseline) {
                    FieldLabel("닉네임")
                    Spacer()
                    Text(viewModel.nicknameCountText)
                        .font(UniTTTypography.labelSmall)
                        .foregroundStyle(UniTTColor.Text.secondary)
                }

                TextField("닉네임", text: $viewModel.nickname)
                    .font(UniTTTypography.bodyMedium)
                    .inputChrome(focused: true)
                    .accessibilityIdentifier("nickname-field")

                HelpText(
                    viewModel.isNicknameValid ? "사용할 수 있는 닉네임이에요." : "닉네임은 2-10자로 입력해 주세요.",
                    color: viewModel.isNicknameValid ? UniTTColor.State.success : UniTTColor.State.danger
                )

                HelpText("한글·영문·숫자 조합 2-10자 / 욕설·연락처는 사용 불가")
            }

            VerificationNotice(universityName: viewModel.selectedUniversity?.name ?? "서울대학교")
                .padding(.top, UniTTSpacing.Stack.loose)

            SectionLabel("미리보기")
                .padding(.top, UniTTSpacing.Stack.loose)

            ProfilePreview(
                nickname: viewModel.nickname,
                universityName: viewModel.selectedUniversity?.name ?? "서울대학교",
                image: avatarImage
            )
        }
        .task(id: selectedPhoto) {
            await loadSelectedPhoto()
        }
        .accessibilityIdentifier("profile-setup-screen")
    }

    private func loadSelectedPhoto() async {
        guard let selectedPhoto else { return }
        guard let data = try? await selectedPhoto.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }

        await MainActor.run {
            avatarImage = Image(uiImage: uiImage)
            viewModel.hasProfilePhoto = true
        }
    }
}

private struct OnboardingCompleteScreen: View {
    var body: some View {
        VStack(spacing: UniTTSpacing.Stack.relaxed) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(UniTTColor.State.success)
                .accessibilityHidden(true)

            Text("온보딩 완료")
                .font(UniTTTypography.heading1)
                .foregroundStyle(UniTTColor.Text.primary)

            Text("유니트 홈 화면은 다음 그룹에서 이어서 만들 예정이에요.")
                .font(UniTTTypography.bodyMedium)
                .foregroundStyle(UniTTColor.Text.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(UniTTSpacing.Inset.loose)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(UniTTColor.Background.page)
        .accessibilityIdentifier("onboarding-complete-screen")
    }
}

private struct OnboardingScreenScaffold<Content: View>: View {
    let title: String
    let step: OnboardingStep
    let backAction: (() -> Void)?
    let rightText: String?
    let showsCTA: Bool
    let ctaTitle: String
    let ctaEnabled: Bool
    let ctaAction: () -> Void
    let content: Content

    init(
        title: String,
        step: OnboardingStep,
        backAction: (() -> Void)? = nil,
        rightText: String? = nil,
        showsCTA: Bool = true,
        ctaTitle: String = "",
        ctaEnabled: Bool = true,
        ctaAction: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.step = step
        self.backAction = backAction
        self.rightText = rightText
        self.showsCTA = showsCTA
        self.ctaTitle = ctaTitle
        self.ctaEnabled = ctaEnabled
        self.ctaAction = ctaAction
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                title: title,
                stepNumberText: step.stepNumberText,
                backAction: backAction,
                rightText: rightText
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    content
                }
                .padding(.horizontal, UniTTSpacing.Gutter.page)
                .padding(.top, UniTTSpacing.Stack.relaxed)
                .padding(.bottom, showsCTA ? 96 : UniTTSpacing.Stack.loose)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if showsCTA {
                BottomCTA(
                    title: ctaTitle,
                    enabled: ctaEnabled,
                    action: ctaAction
                )
            }
        }
    }
}

private struct CustomNavigationBar: View {
    let title: String
    let stepNumberText: String?
    let backAction: (() -> Void)?
    let rightText: String?

    var body: some View {
        ZStack {
            Text(title)
                .font(UniTTTypography.heading3)
                .foregroundStyle(UniTTColor.Text.primary)

            HStack {
                if let backAction {
                    Button(action: backAction) {
                        Label("이전", systemImage: "chevron.left")
                            .labelStyle(.titleAndIcon)
                            .font(UniTTTypography.labelMedium)
                    }
                    .frame(minHeight: UniTTSize.touchMinimum)
                    .accessibilityIdentifier("back-button")
                } else {
                    Color.clear.frame(width: 72, height: UniTTSize.touchMinimum)
                }

                Spacer()

                if let stepNumberText {
                    Text(stepNumberText)
                        .font(UniTTTypography.labelSmall)
                        .foregroundStyle(UniTTColor.Text.secondary)
                        .frame(minWidth: 64, alignment: .trailing)
                } else if let rightText {
                    Text(rightText)
                        .font(UniTTTypography.labelMedium)
                        .foregroundStyle(UniTTColor.Text.secondary)
                        .frame(minWidth: 64, alignment: .trailing)
                        .accessibilityIdentifier("skip-text")
                } else {
                    Color.clear.frame(width: 72, height: UniTTSize.touchMinimum)
                }
            }
            .padding(.horizontal, UniTTSpacing.x8)
        }
        .frame(height: UniTTSize.navbarHeight)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(UniTTColor.Border.default)
                .frame(height: 1)
        }
        .background(UniTTColor.Background.elevated)
    }
}

private struct StepIndicator: View {
    let activeCount: Int

    var body: some View {
        HStack(spacing: UniTTSpacing.x6) {
            ForEach(1...4, id: \.self) { index in
                Capsule()
                    .fill(index <= activeCount ? UniTTColor.Brand.primary : UniTTColor.Border.default)
                    .frame(height: 3)
            }
        }
        .accessibilityLabel("진행 단계 \(activeCount) / 4")
    }
}

private struct HeaderCopy: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.snug) {
            Text(title)
                .font(UniTTTypography.displayMedium)
                .foregroundStyle(UniTTColor.Text.primary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(UniTTTypography.bodySmall)
                .foregroundStyle(UniTTColor.Text.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct BottomCTA: View {
    let title: String
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [UniTTColor.Background.page.opacity(0), UniTTColor.Background.page],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: UniTTSpacing.x12)

            Button(action: action) {
                Text(title)
                    .font(UniTTTypography.labelLarge)
                    .foregroundStyle(enabled ? UniTTColor.Text.onBrand : UniTTColor.Text.disabled)
                    .frame(maxWidth: .infinity)
                    .frame(height: UniTTSize.ctaHeight)
                    .background(enabled ? UniTTColor.Brand.primary : UniTTColor.Background.subtle)
                    .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous))
            }
            .disabled(!enabled)
            .accessibilityIdentifier("primary-cta")
            .padding(.horizontal, UniTTSpacing.Gutter.page)
            .padding(.bottom, UniTTSpacing.Stack.relaxed)
            .background(UniTTColor.Background.page)
        }
    }
}

private struct SearchField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.snug) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(UniTTColor.Text.secondary)
                .accessibilityHidden(true)

            TextField(placeholder, text: $text)
                .font(UniTTTypography.bodyMedium)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier("school-search-field")
        }
        .frame(minHeight: UniTTSize.touchMinimum)
        .padding(.horizontal, UniTTSpacing.Inset.cozy)
        .background(UniTTColor.Background.surface)
        .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
                .stroke(UniTTColor.Border.default, lineWidth: 1)
        )
    }
}

private struct SchoolRow: View {
    let university: University
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: UniTTSpacing.Inline.normal) {
                Text("대학")
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(selected ? UniTTColor.Brand.primary : UniTTColor.Text.secondary)
                    .frame(width: 32, height: 32)
                    .background(selected ? UniTTColor.Brand.primarySubtle : UniTTColor.Background.surface)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(selected ? UniTTColor.Brand.primary : UniTTColor.Border.default, lineWidth: 1))

                Text(university.name)
                    .font(UniTTTypography.bodyMedium)
                    .foregroundStyle(UniTTColor.Text.primary)

                Spacer()

                Text(university.district)
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(UniTTColor.Text.secondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(UniTTColor.Text.tertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("school-row-\(university.id)")
        .background(selected ? UniTTColor.Brand.primarySubtle.opacity(0.65) : .clear)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(UniTTColor.Border.default)
                .frame(height: 1)
        }
    }
}

private struct SectionLabel: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(UniTTTypography.labelSmall)
            .foregroundStyle(UniTTColor.Text.secondary)
    }
}

private struct FieldLabel: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(UniTTTypography.labelSmall)
            .foregroundStyle(UniTTColor.Text.secondary)
    }
}

private struct HelpText: View {
    let text: String
    let color: Color

    init(_ text: String, color: Color = UniTTColor.Text.secondary) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(UniTTTypography.labelSmall)
            .foregroundStyle(color)
            .lineSpacing(3)
    }
}

private struct InfoBox: View {
    let title: String
    let lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.snug) {
            Text(title)
                .font(UniTTTypography.bodySmall.weight(.semibold))
                .foregroundStyle(UniTTColor.Text.primary)

            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                ForEach(lines, id: \.self) { line in
                    Text("· \(line)")
                }
            }
            .font(UniTTTypography.labelSmall)
            .foregroundStyle(UniTTColor.Text.secondary)
            .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, UniTTSpacing.Inset.comfortable)
        .padding(.vertical, UniTTSpacing.Inset.cozy)
        .background(UniTTColor.Background.surface)
        .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
    }
}

private struct OTPCells: View {
    let digits: [String]

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.snug) {
            ForEach(Array(digits.enumerated()), id: \.offset) { index, digit in
                Text(digit)
                    .font(UniTTTypography.otp)
                    .foregroundStyle(UniTTColor.Text.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(UniTTColor.Background.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
                            .stroke(index == activeIndex ? UniTTColor.Border.focus : UniTTColor.Border.default, lineWidth: 1)
                    )
                    .overlay {
                        if index == activeIndex && digit.isEmpty {
                            Rectangle()
                                .fill(UniTTColor.Brand.primary)
                                .frame(width: 2, height: 24)
                        }
                    }
            }
        }
        .accessibilityIdentifier("otp-cells")
    }

    private var activeIndex: Int {
        digits.firstIndex(where: { $0.isEmpty }) ?? max(digits.count - 1, 0)
    }
}

private struct NumericKeypad: View {
    let digitAction: (String) -> Void
    let deleteAction: () -> Void
    private let rows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["", "0", "delete"]]

    var body: some View {
        VStack(spacing: UniTTSpacing.Stack.normal) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: UniTTSpacing.Inline.normal) {
                    ForEach(row, id: \.self) { value in
                        keypadButton(value)
                    }
                }
            }
        }
        .padding(.vertical, UniTTSpacing.Inset.comfortable)
        .background(UniTTColor.Background.surface)
        .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous))
    }

    @ViewBuilder
    private func keypadButton(_ value: String) -> some View {
        if value.isEmpty {
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: UniTTSize.touchMinimum)
        } else {
            Button {
                if value == "delete" {
                    deleteAction()
                } else {
                    digitAction(value)
                }
            } label: {
                Group {
                    if value == "delete" {
                        Image(systemName: "delete.left")
                            .font(.system(size: 17, weight: .medium))
                    } else {
                        Text(value)
                            .font(UniTTTypography.heading2)
                    }
                }
                .foregroundStyle(UniTTColor.Text.primary)
                .frame(maxWidth: .infinity)
                .frame(height: UniTTSize.touchMinimum)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(value == "delete" ? "삭제" : value)
            .accessibilityIdentifier(value == "delete" ? "keypad-delete" : "keypad-digit-\(value)")
        }
    }
}

private struct TermRow: View {
    let term: TermAgreement
    let checked: Bool
    let toggleAction: () -> Void
    let detailAction: () -> Void

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.snug) {
            Button(action: toggleAction) {
                CheckBox(checked: checked)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(term.title) 동의")
            .accessibilityIdentifier("term-toggle-\(term.id)")

            Button(action: term.hasDetail ? detailAction : toggleAction) {
                TermsRowContent(
                    checked: checked,
                    title: term.title,
                    tag: term.required ? "[필수]" : "[선택]",
                    emphasized: false,
                    showsDisclosure: term.hasDetail
                )
            }
            .buttonStyle(.plain)
        }
        .frame(minHeight: UniTTSize.touchMinimum)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(UniTTColor.Border.default)
                .frame(height: 1)
        }
    }
}

private struct TermsRowContent: View {
    let checked: Bool
    let title: String
    let tag: String?
    let emphasized: Bool
    let showsDisclosure: Bool

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.snug) {
            if emphasized {
                CheckBox(checked: checked)
            }

            if let tag {
                Text(tag)
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(tag == "[필수]" ? UniTTColor.Brand.primary : UniTTColor.Text.secondary)
            }

            Text(title)
                .font(emphasized ? UniTTTypography.bodyMedium.weight(.semibold) : UniTTTypography.bodyMedium)
                .foregroundStyle(UniTTColor.Text.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if showsDisclosure {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(UniTTColor.Text.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, UniTTSpacing.Inset.cozy)
    }
}

private struct CheckBox: View {
    let checked: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(checked ? UniTTColor.Brand.primary : UniTTColor.Background.elevated)
                .frame(width: 22, height: 22)
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(checked ? UniTTColor.Brand.primary : UniTTColor.Border.strong, lineWidth: 1.5)
                )

            if checked {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(UniTTColor.Text.onBrand)
            }
        }
    }
}

private struct TermDetailSheet: View {
    let term: TermAgreement

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
            Text(term.title)
                .font(UniTTTypography.heading2)
                .foregroundStyle(UniTTColor.Text.primary)

            Text("정식 약관 본문은 추후 연결됩니다. 현재 프로토타입에서는 약관 시트 진입 동작만 확인합니다.")
                .font(UniTTTypography.bodyMedium)
                .foregroundStyle(UniTTColor.Text.secondary)
                .lineSpacing(4)

            Spacer()
        }
        .padding(UniTTSpacing.Inset.loose)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(UniTTColor.Background.page)
    }
}

private struct AvatarPickerLabel: View {
    let image: Image?
    let hasProfilePhoto: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 48, weight: .regular))
                        .foregroundStyle(UniTTColor.Text.tertiary)
                        .frame(width: UniTTSize.avatarXL, height: UniTTSize.avatarXL)
                        .background(UniTTColor.Background.surface)
                }
            }
            .frame(width: UniTTSize.avatarXL, height: UniTTSize.avatarXL)
            .clipShape(Circle())
            .overlay(Circle().stroke(UniTTColor.Border.default, lineWidth: 1))

            Image(systemName: hasProfilePhoto ? "pencil" : "plus")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(UniTTColor.Text.onBrand)
                .frame(width: 32, height: 32)
                .background(UniTTColor.Brand.primary)
                .clipShape(Circle())
                .overlay(Circle().stroke(UniTTColor.Background.page, lineWidth: 3))
        }
        .accessibilityLabel("프로필 사진 선택")
    }
}

private struct VerificationNotice: View {
    let universityName: String

    var body: some View {
        HStack(alignment: .top, spacing: UniTTSpacing.Inline.normal) {
            Text("i")
                .font(UniTTTypography.labelSmall.weight(.bold))
                .foregroundStyle(UniTTColor.Text.onBrand)
                .frame(width: 18, height: 18)
                .background(UniTTColor.Brand.primary)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                Text("학교 인증 완료 · \(universityName)")
                    .font(UniTTTypography.labelSmall.weight(.semibold))
                Text("학번/이메일은 다른 사용자에게 공개되지 않고,\n프로필에는 닉네임과 학교명만 표시돼요.")
                    .font(UniTTTypography.labelSmall)
                    .lineSpacing(3)
            }
            .foregroundStyle(UniTTColor.Brand.primaryPressed)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(UniTTSpacing.Inset.cozy)
        .background(UniTTColor.Brand.primarySubtle)
        .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
                .stroke(UniTTColor.Brand.border, lineWidth: 1)
        )
    }
}

private struct ProfilePreview: View {
    let nickname: String
    let universityName: String
    let image: Image?

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.normal) {
            Group {
                if let image {
                    image.resizable().scaledToFill()
                } else {
                    ZStack {
                        UniTTColor.Background.surface
                        Text("사진")
                            .font(UniTTTypography.labelSmall)
                            .foregroundStyle(UniTTColor.Text.secondary)
                    }
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .overlay(Circle().stroke(UniTTColor.Border.default, lineWidth: 1))

            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                Text(nickname.isEmpty ? "관악김학생" : nickname)
                    .font(UniTTTypography.bodyMedium.weight(.semibold))
                    .foregroundStyle(UniTTColor.Text.primary)

                Text("● \(universityName) 인증")
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(UniTTColor.Brand.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(UniTTSpacing.Inset.cozy)
        .primaryCard()
    }
}

private extension View {
    func inputChrome(focused: Bool) -> some View {
        self
            .frame(minHeight: 48)
            .padding(.horizontal, UniTTSpacing.Inset.cozy)
            .background(UniTTColor.Background.elevated)
            .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
                    .stroke(focused ? UniTTColor.Border.focus : UniTTColor.Border.default, lineWidth: 1)
            )
            .shadow(color: focused ? UniTTColor.Brand.primary.opacity(0.15) : .clear, radius: 0, x: 0, y: 0)
    }
}

#Preview {
    OnboardingFlowView()
}
