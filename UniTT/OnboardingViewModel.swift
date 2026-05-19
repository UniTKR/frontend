//
//  OnboardingViewModel.swift
//  UniTT
//
//  Created by Codex on 5/15/26.
//

import Combine
import Foundation

struct PasswordRule: Identifiable, Hashable {
    let title: String
    let satisfied: Bool

    var id: String { title }
}

enum OnboardingStep: Int, CaseIterable {
    case school
    case email
    case code
    case password
    case terms
    case profile
    case completed

    var progressCount: Int {
        switch self {
        case .school:
            return 1
        case .email:
            return 2
        case .code:
            return 3
        case .password:
            return 4
        case .terms:
            return 5
        case .profile, .completed:
            return 6
        }
    }

    var stepNumberText: String? {
        switch self {
        case .school, .completed:
            return nil
        case .email:
            return "2 / 5"
        case .code:
            return "3 / 6"
        case .password:
            return "4 / 6"
        case .terms:
            return "5 / 6"
        case .profile:
            return "6 / 6"
        }
    }
}

struct University: Identifiable, Equatable {
    let id: String
    let name: String
    let district: String
    let domain: String

    static let popular: [University] = [
        University(id: "snu", name: "서울대학교", district: "관악구", domain: "snu.ac.kr"),
        University(id: "yonsei", name: "연세대학교", district: "서대문구", domain: "yonsei.ac.kr"),
        University(id: "korea", name: "고려대학교", district: "성북구", domain: "korea.ac.kr"),
        University(id: "skku", name: "성균관대학교", district: "종로구", domain: "skku.edu"),
        University(id: "hanyang", name: "한양대학교", district: "성동구", domain: "hanyang.ac.kr"),
        University(id: "cau", name: "중앙대학교", district: "동작구", domain: "cau.ac.kr"),
        University(id: "khu", name: "경희대학교", district: "동대문구", domain: "khu.ac.kr")
    ]
}

struct TermAgreement: Identifiable, Equatable {
    let id: String
    let title: String
    let required: Bool
    let hasDetail: Bool

    static let all: [TermAgreement] = [
        TermAgreement(id: "age", title: "만 14세 이상입니다", required: true, hasDetail: false),
        TermAgreement(id: "service", title: "서비스 이용약관", required: true, hasDetail: true),
        TermAgreement(id: "privacy", title: "개인정보 수집 및 이용", required: true, hasDetail: true),
        TermAgreement(id: "location", title: "위치기반 서비스 약관", required: true, hasDetail: true),
        TermAgreement(id: "marketing", title: "마케팅 정보 수신 (앱푸시·이메일)", required: false, hasDetail: true),
        TermAgreement(id: "night", title: "야간 알림 수신 (21시-08시)", required: false, hasDetail: true)
    ]

    static var requiredIDs: [String] {
        all.filter { $0.required }.map { $0.id }
    }
}

final class OnboardingViewModel: ObservableObject {
    @Published var step: OnboardingStep = .school
    @Published var searchText = ""
    @Published var selectedUniversity: University?
    @Published var emailLocalPart = "student.id"
    @Published var otpDigits = ["4", "2", "9", "", "", ""]
    @Published var password = "Unit1234!"
    @Published var passwordConfirmation = "Unit1234!"
    @Published var acceptedTermIDs: Set<String> = ["age", "service", "privacy", "location", "marketing"]
    @Published var presentedTerm: TermAgreement?
    @Published var nickname = "관악김학생"
    @Published var hasProfilePhoto = false

    var filteredUniversities: [University] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return University.popular }

        return University.popular.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.district.localizedCaseInsensitiveContains(query)
        }
    }

    var canContinueFromSchool: Bool {
        selectedUniversity != nil
    }

    var canSendVerificationEmail: Bool {
        !emailLocalPart.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var emailAddress: String {
        "\(emailLocalPart)@\(selectedUniversity?.domain ?? University.popular[0].domain)"
    }

    var otpCode: String {
        otpDigits.joined()
    }

    var canVerifyCode: Bool {
        otpCode.count == 6 && otpDigits.allSatisfy { $0.count == 1 }
    }

    var passwordRules: [PasswordRule] {
        [
            PasswordRule(title: "8자 이상", satisfied: password.count >= 8),
            PasswordRule(title: "영문 포함", satisfied: password.rangeOfCharacter(from: .letters) != nil),
            PasswordRule(title: "숫자 포함", satisfied: password.rangeOfCharacter(from: .decimalDigits) != nil),
            PasswordRule(title: "특수문자 포함", satisfied: password.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil)
        ]
    }

    var isPasswordValid: Bool {
        passwordRules.allSatisfy { $0.satisfied }
    }

    var doPasswordsMatch: Bool {
        !passwordConfirmation.isEmpty && password == passwordConfirmation
    }

    var canContinuePassword: Bool {
        isPasswordValid && doPasswordsMatch
    }

    var allTermsAccepted: Bool {
        Set(TermAgreement.all.map { $0.id }).isSubset(of: acceptedTermIDs)
    }

    var canContinueTerms: Bool {
        Set(TermAgreement.requiredIDs).isSubset(of: acceptedTermIDs)
    }

    var nicknameCountText: String {
        "\(nickname.count) / 10"
    }

    var isNicknameValid: Bool {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return (2...10).contains(trimmed.count)
    }

    var canFinishProfile: Bool {
        isNicknameValid
    }

    func selectUniversity(_ university: University) {
        selectedUniversity = university
    }

    func goBack() {
        switch step {
        case .school:
            break
        case .email:
            step = .school
        case .code:
            step = .email
        case .terms:
            step = .password
        case .password:
            step = .code
        case .profile:
            step = .terms
        case .completed:
            step = .profile
        }
    }

    func continueFromCurrentStep() {
        switch step {
        case .school where canContinueFromSchool:
            step = .email
        case .email where canSendVerificationEmail:
            step = .code
        case .code where canVerifyCode:
            step = .password
        case .password where canContinuePassword:
            step = .terms
        case .terms where canContinueTerms:
            step = .profile
        case .profile where canFinishProfile:
            step = .completed
        default:
            break
        }
    }

    func appendOTPDigit(_ digit: String) {
        guard digit.count == 1, digit.allSatisfy(\.isNumber) else { return }
        guard let index = otpDigits.firstIndex(where: { $0.isEmpty }) else { return }

        otpDigits[index] = digit

        if canVerifyCode {
            step = .password
        }
    }

    func removeLastOTPDigit() {
        guard let index = otpDigits.lastIndex(where: { !$0.isEmpty }) else { return }
        otpDigits[index] = ""
    }

    func toggleTerm(_ term: TermAgreement) {
        if acceptedTermIDs.contains(term.id) {
            acceptedTermIDs.remove(term.id)
        } else {
            acceptedTermIDs.insert(term.id)
        }
    }

    func setAllTermsAccepted(_ accepted: Bool) {
        if accepted {
            acceptedTermIDs = Set(TermAgreement.all.map { $0.id })
        } else {
            acceptedTermIDs = []
        }
    }
}
