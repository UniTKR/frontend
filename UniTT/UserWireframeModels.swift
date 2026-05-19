//
//  UserWireframeModels.swift
//  UniTT
//
//  Created by Codex on 5/15/26.
//

import Combine
import Foundation

enum UserTab: String, CaseIterable, Identifiable {
    case home = "홈"
    case search = "검색"
    case create = "등록"
    case chat = "채팅"
    case my = "마이"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .home:
            return "house.fill"
        case .search:
            return "magnifyingglass"
        case .create:
            return "plus.circle.fill"
        case .chat:
            return "bubble.left.and.bubble.right.fill"
        case .my:
            return "person.crop.circle.fill"
        }
    }
}

enum ListingStatus: String {
    case listed = "거래중"
    case reserved = "예약중"
    case completed = "거래완료"
    case canceled = "취소됨"
    case disputed = "분쟁중"
}

struct MockListing: Identifiable, Hashable {
    let id: String
    let title: String
    let category: String
    let price: String
    let spot: String
    let time: String
    let status: ListingStatus
    let description: String
    let seller: String
    let isMine: Bool
}

struct MockChat: Identifiable, Hashable {
    let id: String
    let name: String
    let listingTitle: String
    let lastMessage: String
    let time: String
    let unreadCount: Int
}

struct MockNotification: Identifiable, Hashable {
    let id: String
    let title: String
    let body: String
    let kind: String
    let time: String
}

enum ListingCreateCategory: String, CaseIterable, Identifiable {
    case textbook = "교재"
    case electronics = "전자기기"
    case living = "자취·기숙사"
    case moving = "이사·나눔"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .textbook:
            return "book.closed.fill"
        case .electronics:
            return "laptopcomputer"
        case .living:
            return "house.fill"
        case .moving:
            return "shippingbox.fill"
        }
    }

    var detailHint: String {
        switch self {
        case .textbook:
            return "ISBN, 과목코드, 학기"
        case .electronics:
            return "모델명, 보증, 이상 부위"
        case .living:
            return "자취촌, 직접 픽업, 크기"
        case .moving:
            return "마감일, 일괄 처리, 무료 나눔"
        }
    }
}

enum ReportTarget: String, CaseIterable, Identifiable {
    case listing = "상품"
    case user = "사용자"
    case chat = "채팅방"
    case trade = "거래"

    var id: String { rawValue }
}

enum NotificationTab: String, CaseIterable, Identifiable {
    case trade = "거래"
    case chat = "채팅"
    case system = "시스템"

    var id: String { rawValue }
}

enum PrototypeRoute {
    case main
    case productDetail(MockListing)
    case report
    case notifications
    case blockList
    case settings
    case history
    case chatRoom(MockChat)
    case tradePanel
    case review
    case withdraw
}

enum CreateStep: Int, CaseIterable {
    case category
    case info
    case textbook
    case pickup
    case preview
    case done
}

enum ReportStep: Int {
    case target
    case reason
    case detail
    case done
}

final class UserWireframeViewModel: ObservableObject {
    @Published var activeTab: UserTab = .home
    @Published var route: PrototypeRoute = .main
    @Published var selectedCategory = "전체"
    @Published var searchText = ""
    @Published var createStep: CreateStep = .category
    @Published var createCategory = "교재"
    @Published var createTitle = "자료구조 솔루션 매뉴얼 9판"
    @Published var createPrice = "8000"
    @Published var createDescription = "필기 거의 없고 깨끗해요. 학생회관에서 거래 가능합니다."
    @Published var createCondition = "상"
    @Published var createPickup = "학생회관"
    @Published var reportStep: ReportStep = .target
    @Published var reportTarget: ReportTarget = .listing
    @Published var reportReason = ""
    @Published var reportDetail = "거래 약속 후 반복적으로 연락이 되지 않았고 다른 학생에게도 같은 행동을 했습니다."
    @Published var tradeStatus: ListingStatus = .reserved
    @Published var reviewRating = 0
    @Published var reviewComment = "약속 시간 잘 지켜주셨어요. 거래가 깔끔했습니다."
    @Published var showingAppointmentSheet = false
    @Published var showingHistoryActions = false
    @Published var showingLogoutDialog = false
    @Published var showingEmptyFeed = false
    @Published var showingCreateError = false
    @Published var showingMapPickup = false
    @Published var showingChatActions = false
    @Published var showingBlockToast = false
    @Published var notificationTab: NotificationTab = .trade
    @Published var pushEnabled = true
    @Published var marketingEnabled = false

    let categories = ["전체", "교재", "전자기기", "자취·기숙사", "이사·나눔"]
    let reportReasons = ["사기 의심", "노쇼/약속 불이행", "금지 물품", "욕설/괴롭힘", "기타"]
    let recentSearches = ["에어팟", "자료구조", "미니냉장고"]
    let pickupSpots = ["학생회관", "정문", "중앙도서관", "공대 301동", "후문 GS25"]

    let listings: [MockListing] = [
        MockListing(id: "data-structure", title: "자료구조 솔루션 매뉴얼 9판 (한빛, 깨끗함)", category: "교재", price: "8,000원", spot: "학생회관", time: "2분 전", status: .listed, description: "중간고사 전까지 사용했고 필기는 거의 없습니다. 학생회관 1층에서 거래 가능해요.", seller: "관악김학생", isMine: false),
        MockListing(id: "airpods", title: "에어팟 4세대 USB-C (보증 9개월 남음)", category: "전자기기", price: "130,000원", spot: "정문", time: "12분 전", status: .listed, description: "구성품 모두 있고 케이스 생활기스만 조금 있어요.", seller: "공대박학생", isMine: false),
        MockListing(id: "fridge", title: "미니냉장고 (자취 정리, 직접 픽업만)", category: "자취·기숙사", price: "50,000원", spot: "후문 GS25", time: "1시간 전", status: .reserved, description: "소음 적고 냉장 잘 됩니다. 직접 픽업만 가능해요.", seller: "후문정리왕", isMine: false),
        MockListing(id: "physics", title: "일반물리학 13판 솔루션 (Halliday)", category: "교재", price: "12,000원", spot: "도서관 입구", time: "3시간 전", status: .listed, description: "표지 접힘 약간 있고 내부는 깨끗합니다.", seller: "자연대학생", isMine: false),
        MockListing(id: "chair", title: "책상 의자 (이사 나눔, 27동 픽업)", category: "이사·나눔", price: "무료 나눔", spot: "27동 1층", time: "5시간 전", status: .listed, description: "사용감 있지만 튼튼합니다. 오늘 저녁 픽업 가능해요.", seller: "27동이사", isMine: true),
        MockListing(id: "monitor", title: "LG 모니터 24인치 (1080p, 픽업 완료)", category: "전자기기", price: "80,000원", spot: "공대", time: "어제", status: .completed, description: "거래 완료된 상품입니다.", seller: "관악김학생", isMine: true),
        MockListing(id: "calculator", title: "공학용 계산기 FX-570ES", category: "전자기기", price: "18,000원", spot: "중앙도서관", time: "어제", status: .canceled, description: "거래가 취소된 상품입니다.", seller: "관악김학생", isMine: true)
    ]

    let chats: [MockChat] = [
        MockChat(id: "chat-airpods", name: "공대박학생", listingTitle: "에어팟 4세대 USB-C", lastMessage: "그럼 정문에서 6시에 뵐게요.", time: "방금", unreadCount: 2),
        MockChat(id: "chat-fridge", name: "후문정리왕", listingTitle: "미니냉장고", lastMessage: "픽업은 오늘 저녁 가능합니다.", time: "12분 전", unreadCount: 0)
    ]

    let notifications: [MockNotification] = [
        MockNotification(id: "trade", title: "거래 약속이 확정됐어요", body: "에어팟 4세대 · 정문 · 오늘 18:00", kind: "거래", time: "방금"),
        MockNotification(id: "chat", title: "새 채팅 메시지", body: "공대박학생: 그럼 정문에서 6시에 뵐게요.", kind: "채팅", time: "2분 전"),
        MockNotification(id: "system", title: "신고 접수 안내", body: "접수하신 신고는 운영팀 검토 중입니다.", kind: "시스템", time: "어제")
    ]

    let blockedUsers = ["노쇼상습러", "스팸계정12", "외부거래유도", "비매너거래"]

    var visibleListings: [MockListing] {
        guard !showingEmptyFeed else { return [] }
        listings.filter { listing in
            selectedCategory == "전체" || listing.category == selectedCategory
        }
    }

    var searchResults: [MockListing] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }
        return listings.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.category.localizedCaseInsensitiveContains(query)
        }
    }

    var canSubmitListing: Bool {
        guard !showingCreateError else { return false }
        !createCategory.isEmpty &&
        !createTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !createPrice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !createDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !createPickup.isEmpty
    }

    var canContinueReport: Bool {
        switch reportStep {
        case .target:
            return true
        case .reason:
            return !reportReason.isEmpty
        case .detail:
            return reportDetail.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
        case .done:
            return false
        }
    }

    var canSubmitReview: Bool {
        reviewRating > 0
    }

    var selectedCreateCategory: ListingCreateCategory {
        ListingCreateCategory(rawValue: createCategory) ?? .textbook
    }

    var visibleNotifications: [MockNotification] {
        notifications.filter { $0.kind == notificationTab.rawValue }
    }

    func resetToHome() {
        route = .main
        activeTab = .home
        showingEmptyFeed = false
    }

    func openTab(_ tab: UserTab) {
        route = .main
        activeTab = tab
    }

    func openSearch(with query: String = "") {
        searchText = query
        openTab(.search)
    }

    func selectCreateCategory(_ category: ListingCreateCategory) {
        createCategory = category.rawValue
    }

    func nextCreateStep() {
        guard createStep != .done else { return }
        if createStep == .preview {
            createStep = .done
        } else if let next = CreateStep(rawValue: createStep.rawValue + 1) {
            createStep = next
        }
    }

    func resetCreateFlow() {
        createStep = .category
        showingCreateError = false
        showingMapPickup = false
        activeTab = .home
        route = .main
    }

    func nextReportStep() {
        switch reportStep {
        case .target:
            reportStep = .reason
        case .reason where canContinueReport:
            reportStep = .detail
        case .detail where canContinueReport:
            reportStep = .done
        case .reason, .detail, .done:
            break
        }
    }

    func startReport() {
        reportStep = .target
        reportTarget = .listing
        reportReason = ""
        route = .report
    }

    func completeTrade() {
        tradeStatus = .completed
    }

    func disputeTrade() {
        tradeStatus = .disputed
        startReport()
        reportTarget = .trade
    }

    func blockCurrentUser() {
        showingBlockToast = true
        route = .blockList
    }

    func requestLogout() {
        showingLogoutDialog = true
    }
}
