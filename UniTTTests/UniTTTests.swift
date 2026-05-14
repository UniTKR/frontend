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

}
