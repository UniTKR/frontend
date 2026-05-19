//
//  UniTTTests.swift
//  UniTTTests
//
//  Created by 천승환 on 5/15/26.
//

import Testing
@testable import UniTT

struct UniTTTests {

    @Test func schoolSelectionControlsContinue() {
        let viewModel = OnboardingViewModel()

        #expect(viewModel.canContinueFromSchool == false)

        viewModel.selectUniversity(University.popular[0])

        #expect(viewModel.canContinueFromSchool == true)
        #expect(viewModel.selectedUniversity?.name == "서울대학교")
    }

    @Test func emailLocalPartControlsVerificationCTA() {
        let viewModel = OnboardingViewModel()

        viewModel.emailLocalPart = "student.id"
        #expect(viewModel.canSendVerificationEmail == true)

        viewModel.emailLocalPart = "   "
        #expect(viewModel.canSendVerificationEmail == false)
    }

    @Test func otpRequiresSixDigits() {
        let viewModel = OnboardingViewModel()

        viewModel.otpDigits = ["1", "2", "3", "4", "5", ""]
        #expect(viewModel.canVerifyCode == false)

        viewModel.otpDigits = ["1", "2", "3", "4", "5", "6"]
        #expect(viewModel.canVerifyCode == true)
        #expect(viewModel.otpCode == "123456")
    }

    @Test func requiredTermsControlContinue() {
        let viewModel = OnboardingViewModel()

        viewModel.acceptedTermIDs = Set(TermAgreement.requiredIDs)
        #expect(viewModel.canContinueTerms == true)

        viewModel.acceptedTermIDs.remove("privacy")
        #expect(viewModel.canContinueTerms == false)
    }

    @Test func nicknameRequiresTwoToTenCharacters() {
        let viewModel = OnboardingViewModel()

        viewModel.nickname = "김"
        #expect(viewModel.isNicknameValid == false)

        viewModel.nickname = "관악김학생"
        #expect(viewModel.isNicknameValid == true)

        viewModel.nickname = "열한글자닉네임입니다요"
        #expect(viewModel.isNicknameValid == false)
    }

    @Test func signupPasswordRequiresRulesAndMatch() {
        let viewModel = OnboardingViewModel()

        viewModel.password = "short"
        viewModel.passwordConfirmation = "short"
        #expect(viewModel.canContinuePassword == false)

        viewModel.password = "Unit1234!"
        viewModel.passwordConfirmation = "Unit1234?"
        #expect(viewModel.canContinuePassword == false)

        viewModel.passwordConfirmation = "Unit1234!"
        #expect(viewModel.canContinuePassword == true)
    }

    @Test func authLoginAndPasswordResetValidation() {
        let viewModel = AuthViewModel()

        viewModel.loginEmail = "student.id@snu.ac.kr"
        viewModel.loginPassword = "Unit1234!"
        #expect(viewModel.canLogin == true)

        viewModel.loginPassword = ""
        #expect(viewModel.canLogin == false)

        viewModel.newPassword = "Unit1234!"
        viewModel.newPasswordConfirmation = "Unit1234!"
        #expect(viewModel.canResetPassword == true)
    }

    @Test func searchFiltersListingsByKeyword() {
        let viewModel = UserWireframeViewModel()

        #expect(viewModel.searchResults.isEmpty)

        viewModel.searchText = "에어팟"

        #expect(viewModel.searchResults.count == 1)
        #expect(viewModel.searchResults.first?.id == "airpods")
    }

    @Test func listingCreateRequiresEssentialFields() {
        let viewModel = UserWireframeViewModel()

        #expect(viewModel.canSubmitListing == true)

        viewModel.createTitle = "   "
        #expect(viewModel.canSubmitListing == false)

        viewModel.createTitle = "자료구조 솔루션 매뉴얼 9판"
        viewModel.createPickup = ""
        #expect(viewModel.canSubmitListing == false)
    }

    @Test func createCategoryBranchCanChange() {
        let viewModel = UserWireframeViewModel()

        #expect(viewModel.selectedCreateCategory == .textbook)

        viewModel.selectCreateCategory(.electronics)

        #expect(viewModel.createCategory == "전자기기")
        #expect(viewModel.selectedCreateCategory == .electronics)
    }

    @Test func reportRequiresReasonAndDetail() {
        let viewModel = UserWireframeViewModel()

        viewModel.reportStep = .reason
        #expect(viewModel.canContinueReport == false)

        viewModel.reportReason = "노쇼/약속 불이행"
        #expect(viewModel.canContinueReport == true)

        viewModel.reportStep = .detail
        viewModel.reportDetail = "짧음"
        #expect(viewModel.canContinueReport == false)
    }

    @Test func tradeStatusCanMoveToCompleted() {
        let viewModel = UserWireframeViewModel()

        #expect(viewModel.tradeStatus == .reserved)

        viewModel.completeTrade()

        #expect(viewModel.tradeStatus == .completed)
    }

    @Test func notificationTabFiltersNotifications() {
        let viewModel = UserWireframeViewModel()

        viewModel.notificationTab = .system

        #expect(viewModel.visibleNotifications.count == 1)
        #expect(viewModel.visibleNotifications.first?.kind == "시스템")
    }

    @Test func logoutDialogStateIsRequestedFromSettings() {
        let viewModel = UserWireframeViewModel()

        #expect(viewModel.showingLogoutDialog == false)

        viewModel.requestLogout()

        #expect(viewModel.showingLogoutDialog == true)
    }

}
