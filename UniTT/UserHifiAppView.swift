//
//  UserHifiAppView.swift
//  UniTT
//
//  Created by Codex on 5/20/26.
//

import SwiftUI

struct UserHifiAppView: View {
    @StateObject private var viewModel = UserWireframeViewModel()

    var body: some View {
        ZStack {
            UniTTColor.Background.page.ignoresSafeArea()

            switch viewModel.route {
            case .main:
                HifiMainTabShell(viewModel: viewModel)
            case .productDetail(let listing):
                HifiProductDetailScreen(viewModel: viewModel, listing: listing)
            case .report:
                HifiReportFlowScreen(viewModel: viewModel)
            case .notifications:
                HifiNotificationsScreen(viewModel: viewModel)
            case .blockList:
                HifiBlockListScreen(viewModel: viewModel)
            case .settings:
                HifiSettingsScreen(viewModel: viewModel)
            case .history:
                HifiHistoryScreen(viewModel: viewModel)
            case .chatRoom(let chat):
                HifiChatRoomScreen(viewModel: viewModel, chat: chat)
            case .tradePanel:
                HifiTradePanelScreen(viewModel: viewModel)
            case .review:
                HifiReviewScreen(viewModel: viewModel)
            case .withdraw:
                HifiWithdrawScreen(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $viewModel.showingAppointmentSheet) {
            HifiAppointmentSheet(viewModel: viewModel)
                .presentationDetents([.medium])
        }
        .alert("로그아웃할까요?", isPresented: $viewModel.showingLogoutDialog) {
            Button("취소", role: .cancel) {}
            Button("로그아웃", role: .destructive) {
                viewModel.showingLogoutDialog = false
            }
        } message: {
            Text("프로토타입에서는 실제 세션을 종료하지 않아요.")
        }
    }
}

private struct HifiMainTabShell: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch viewModel.activeTab {
                case .home:
                    HifiHomeFeedScreen(viewModel: viewModel)
                case .search:
                    HifiSearchScreen(viewModel: viewModel)
                case .create:
                    HifiListingCreateScreen(viewModel: viewModel)
                case .chat:
                    HifiChatListScreen(viewModel: viewModel)
                case .my:
                    HifiMyPageScreen(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HifiBottomTabBar(viewModel: viewModel)
        }
    }
}

private struct HifiHomeFeedScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                HStack(spacing: UniTTSpacing.Inline.normal) {
                    Image("UniTTGlyph")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: UniTTSpacing.x2) {
                        Text("서울대학교")
                            .font(UniTTTypography.heading3)
                            .foregroundStyle(UniTTColor.Text.primary)
                        Text("학교 인증 피드")
                            .font(UniTTTypography.labelSmall)
                            .foregroundStyle(UniTTColor.Text.secondary)
                    }

                    Spacer()

                    Button {
                        viewModel.route = .notifications
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: UniTTSize.touchMinimum, height: UniTTSize.touchMinimum)
                    }
                    .foregroundStyle(UniTTColor.Text.primary)
                    .accessibilityIdentifier("home-notifications-button")
                }

                Button {
                    viewModel.openSearch()
                } label: {
                    HStack(spacing: UniTTSpacing.Inline.snug) {
                        Image(systemName: "magnifyingglass")
                            .accessibilityHidden(true)
                        Text("검색어를 입력해 보세요")
                        Spacer()
                    }
                    .font(UniTTTypography.bodyMedium)
                    .foregroundStyle(UniTTColor.Text.secondary)
                    .frame(minHeight: UniTTSize.inputHeight)
                    .padding(.horizontal, UniTTSpacing.Inset.cozy)
                    .background(UniTTColor.Background.surface)
                    .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous)
                            .stroke(UniTTColor.Border.default, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("home-search-button")

                HifiSectionHeader(title: "카테고리", trailing: viewModel.showingEmptyFeed ? "피드 보기" : "첫 방문 보기") {
                    viewModel.showingEmptyFeed.toggle()
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: UniTTSpacing.Inline.snug) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            HifiChip(
                                title: category,
                                selected: viewModel.selectedCategory == category
                            ) {
                                viewModel.selectedCategory = category
                                viewModel.showingEmptyFeed = false
                            }
                            .accessibilityIdentifier(category == "교재" ? "category-textbook-button" : "category-\(category)")
                        }
                    }
                }

                if viewModel.selectedCategory == "교재" {
                    HStack(spacing: UniTTSpacing.Inline.snug) {
                        HifiFilterChip(title: "ISBN")
                        HifiFilterChip(title: "과목코드")
                        HifiFilterChip(title: "이번 학기")
                    }
                    .accessibilityIdentifier("textbook-filter-row")
                }

                if viewModel.visibleListings.isEmpty {
                    HifiEmptyState(
                        systemImage: "tray",
                        title: "아직 올라온 매물이 없어요",
                        subtitle: "카테고리 알림을 켜두면 새 매물이 올라올 때 알려드릴게요.",
                        actionTitle: "매물 등록하기"
                    ) {
                        viewModel.openTab(.create)
                    }
                    .accessibilityIdentifier("home-empty-feed")
                } else {
                    VStack(spacing: UniTTSpacing.Stack.normal) {
                        ForEach(viewModel.visibleListings) { listing in
                            Button {
                                viewModel.route = .productDetail(listing)
                            } label: {
                                HifiListingCard(listing: listing)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("product-card-\(listing.id)")
                        }
                    }
                }
            }
            .padding(UniTTSpacing.Gutter.page)
            .padding(.bottom, UniTTSpacing.x24)
        }
        .background(UniTTColor.Background.page)
        .accessibilityIdentifier("user-home-screen")
    }
}

private struct HifiSearchScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            HifiTopBar(title: "검색") {
                viewModel.resetToHome()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                    HStack(spacing: UniTTSpacing.Inline.snug) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(UniTTColor.Text.secondary)
                        TextField("에어팟, 자료구조, 냉장고", text: $viewModel.searchText)
                            .font(UniTTTypography.bodyMedium)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .accessibilityIdentifier("search-field")
                    }
                    .inputChrome(focused: true)

                    if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        HifiSectionHeader(title: "인기 검색어")
                        VStack(spacing: UniTTSpacing.Stack.snug) {
                            ForEach(viewModel.recentSearches, id: \.self) { item in
                                Button {
                                    viewModel.searchText = item
                                } label: {
                                    HifiSuggestionRow(title: item, subtitle: "서울대학교에서 최근 많이 찾았어요")
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier(item == "에어팟" ? "recent-search-airpods" : "recent-search-\(item)")
                            }
                        }
                    } else if viewModel.searchResults.isEmpty {
                        HifiEmptyState(
                            systemImage: "magnifyingglass",
                            title: "검색 결과가 없어요",
                            subtitle: "저장해 두면 새 매물이 올라올 때 알려드릴게요.",
                            actionTitle: "알림 받기"
                        ) {
                            viewModel.notificationTab = .system
                            viewModel.route = .notifications
                        }
                        .accessibilityIdentifier("search-empty-screen")
                    } else {
                        HifiSectionHeader(title: "검색 결과", trailing: "\(viewModel.searchResults.count)건")
                        VStack(spacing: UniTTSpacing.Stack.normal) {
                            ForEach(viewModel.searchResults) { listing in
                                Button {
                                    viewModel.route = .productDetail(listing)
                                } label: {
                                    HifiListingCard(listing: listing)
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("search-result-\(listing.id)")
                            }
                        }
                    }
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .background(UniTTColor.Background.page)
        .accessibilityIdentifier("search-screen")
    }
}

private struct HifiProductDetailScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel
    let listing: MockListing

    var body: some View {
        VStack(spacing: 0) {
            HifiTopBar(
                title: "상품 상세",
                backAction: { viewModel.route = .main },
                rightSystemImage: "ellipsis",
                rightAction: { viewModel.startReport() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                    RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous)
                        .fill(UniTTColor.Background.surface)
                        .frame(height: 260)
                        .overlay {
                            VStack(spacing: UniTTSpacing.Stack.snug) {
                                Image(systemName: "photo")
                                    .font(.system(size: 36))
                                Text(listing.category)
                                    .font(UniTTTypography.labelMedium)
                            }
                            .foregroundStyle(UniTTColor.Text.tertiary)
                        }

                    if listing.status == .reserved {
                        HifiNoticeRow(
                            title: "예약중인 상품이에요",
                            subtitle: "대기열에 등록하면 예약 취소 시 알려드려요.",
                            style: .warning
                        )
                        .accessibilityIdentifier("product-reserved-banner")
                    }

                    VStack(alignment: .leading, spacing: UniTTSpacing.Stack.snug) {
                        HifiStatusChip(status: listing.status)
                        Text(listing.title)
                            .font(UniTTTypography.heading1)
                            .foregroundStyle(UniTTColor.Text.primary)
                            .lineSpacing(2)
                        Text(listing.price)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(listing.price.contains("무료") ? UniTTColor.Brand.primary : UniTTColor.Text.primary)
                        Text("\(listing.spot) · \(listing.time)")
                            .font(UniTTTypography.bodySmall)
                            .foregroundStyle(UniTTColor.Text.secondary)
                    }

                    HifiSellerCard(name: listing.seller, isMine: listing.isMine)

                    VStack(alignment: .leading, spacing: UniTTSpacing.Stack.snug) {
                        HifiSectionHeader(title: "상품 설명")
                        Text(listing.description)
                            .font(UniTTTypography.bodyMedium)
                            .foregroundStyle(UniTTColor.Text.primary)
                            .lineSpacing(5)
                    }

                    HStack(spacing: UniTTSpacing.Inline.normal) {
                        HifiTrustMetric(value: "12건", label: "거래")
                        HifiTrustMetric(value: "98%", label: "응답")
                        HifiTrustMetric(value: "4.8", label: "평점")
                    }

                    if listing.isMine {
                        HStack(spacing: UniTTSpacing.Inline.snug) {
                            Button("수정") {}
                                .buttonStyle(HifiSecondaryButtonStyle())
                            Button("판매완료") {
                                viewModel.completeTrade()
                            }
                            .buttonStyle(HifiPrimaryButtonStyle())
                        }
                        .accessibilityIdentifier("owner-product-actions")
                    } else if listing.status == .reserved {
                        Button("대기열 등록") {
                            viewModel.notificationTab = .trade
                            viewModel.route = .notifications
                        }
                        .buttonStyle(HifiSecondaryButtonStyle())
                        .accessibilityIdentifier("join-waitlist-button")
                    } else {
                        Button("채팅하기") {
                            if let chat = viewModel.chats.first {
                                viewModel.route = .chatRoom(chat)
                            }
                        }
                        .buttonStyle(HifiPrimaryButtonStyle())
                        .accessibilityIdentifier("start-chat-button")
                    }
                }
                .padding(UniTTSpacing.Gutter.page)
                .padding(.bottom, UniTTSpacing.x32)
            }
        }
        .background(UniTTColor.Background.page)
        .accessibilityIdentifier("product-detail-screen")
    }
}

private struct HifiListingCreateScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            HifiTopBar(title: "판매글 등록")

            if viewModel.createStep == .done {
                HifiCreateDoneScreen(viewModel: viewModel)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                        HifiCreateProgress(step: viewModel.createStep)

                        switch viewModel.createStep {
                        case .category:
                            HifiCreateCategoryStep(viewModel: viewModel)
                        case .info:
                            HifiCreateInfoStep(viewModel: viewModel)
                        case .textbook:
                            HifiCreateSpecificStep(viewModel: viewModel)
                        case .pickup:
                            HifiCreatePickupStep(viewModel: viewModel)
                        case .preview:
                            HifiCreatePreviewStep(viewModel: viewModel)
                        case .done:
                            EmptyView()
                        }

                        Button(viewModel.createStep == .preview ? "등록하기" : "다음") {
                            viewModel.nextCreateStep()
                        }
                        .buttonStyle(HifiPrimaryButtonStyle(enabled: viewModel.canSubmitListing || viewModel.createStep == .category || viewModel.createStep == .textbook || viewModel.createStep == .pickup))
                        .disabled(!(viewModel.canSubmitListing || viewModel.createStep == .category || viewModel.createStep == .textbook || viewModel.createStep == .pickup))
                        .accessibilityIdentifier(viewModel.createStep == .preview ? "create-submit" : "create-next")
                    }
                    .padding(UniTTSpacing.Gutter.page)
                    .padding(.bottom, UniTTSpacing.x32)
                }
            }
        }
        .background(UniTTColor.Background.page)
        .accessibilityIdentifier("listing-create-screen")
    }
}

private struct HifiCreateCategoryStep: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.normal) {
            HifiHeaderTitle(title: "어떤 물건을\n등록할까요?", subtitle: "카테고리에 맞춰 필요한 정보만 이어서 받아요.")

            ForEach(ListingCreateCategory.allCases) { category in
                Button {
                    viewModel.selectCreateCategory(category)
                } label: {
                    HStack(spacing: UniTTSpacing.Inline.normal) {
                        Image(systemName: category.systemImageName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(UniTTColor.Brand.primary)
                            .frame(width: 40, height: 40)
                            .background(UniTTColor.Brand.primarySubtle)
                            .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.md, style: .continuous))

                        VStack(alignment: .leading, spacing: UniTTSpacing.x4) {
                            Text(category.rawValue)
                                .font(UniTTTypography.bodyMedium.weight(.semibold))
                                .foregroundStyle(UniTTColor.Text.primary)
                            Text(category.detailHint)
                                .font(UniTTTypography.labelSmall)
                                .foregroundStyle(UniTTColor.Text.secondary)
                        }

                        Spacer()

                        Image(systemName: viewModel.selectedCreateCategory == category ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(viewModel.selectedCreateCategory == category ? UniTTColor.Brand.primary : UniTTColor.Text.tertiary)
                    }
                    .padding(UniTTSpacing.Inset.comfortable)
                    .primaryCard()
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(category == .textbook ? "create-category-textbook" : "create-category-\(category.rawValue)")
            }
        }
    }
}

private struct HifiCreateInfoStep: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
            HifiHeaderTitle(title: "사진과 기본 정보를\n입력해 주세요", subtitle: "첫 사진이 대표 이미지로 사용돼요.")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: UniTTSpacing.Inline.snug) {
                    ForEach(0..<4, id: \.self) { index in
                        HifiPhotoSlot(index: index)
                    }
                }
            }

            HifiFormField(title: "제목", text: $viewModel.createTitle, placeholder: "상품명을 입력해 주세요")
            HifiFormField(title: "가격", text: $viewModel.createPrice, placeholder: "가격")
            HifiFormField(title: "상태", text: $viewModel.createCondition, placeholder: "상 / 중 / 하")
            HifiFormField(title: "설명", text: $viewModel.createDescription, placeholder: "상품 상태와 거래 조건")

            Button(viewModel.showingCreateError ? "에러 숨기기" : "에러 상태 보기") {
                viewModel.showingCreateError.toggle()
            }
            .font(UniTTTypography.labelMedium)
            .foregroundStyle(UniTTColor.Brand.primary)
            .accessibilityIdentifier("create-error-toggle")

            if viewModel.showingCreateError {
                HifiNoticeRow(
                    title: "등록할 수 없는 표현이 포함되어 있어요",
                    subtitle: "금지어·가격 이상은 제출 전 다시 확인돼요.",
                    style: .danger
                )
                .accessibilityIdentifier("create-error-panel")
            }
        }
    }
}

private struct HifiCreateSpecificStep: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
            HifiHeaderTitle(
                title: "\(viewModel.createCategory) 정보를\n조금 더 알려주세요",
                subtitle: "선택한 카테고리에 맞춰 검색과 상세 노출에 필요한 정보를 받아요."
            )

            switch viewModel.selectedCreateCategory {
            case .textbook:
                HifiFormField(title: "ISBN", text: .constant("978-89-7914-900-9"), placeholder: "ISBN")
                HifiFormField(title: "과목코드", text: .constant("M1522.000900"), placeholder: "과목코드")
                HifiSuggestionRow(title: "자료구조 솔루션 9판", subtitle: "자동완성 결과 · 한빛아카데미")
                    .accessibilityIdentifier("isbn-autocomplete-row")
            case .electronics:
                HifiFormField(title: "모델명", text: .constant("AirPods 4 USB-C"), placeholder: "모델명")
                HifiFilterChip(title: "보증 9개월")
                HifiFilterChip(title: "생활기스")
            case .living:
                HifiFormField(title: "자취촌", text: .constant("녹두거리"), placeholder: "자취촌")
                HifiFilterChip(title: "직접 픽업")
                HifiFilterChip(title: "동일 자취촌 우선")
            case .moving:
                HifiFormField(title: "픽업 마감", text: .constant("D-1"), placeholder: "마감일")
                HifiFilterChip(title: "무료 나눔")
                HifiFilterChip(title: "일괄 처리")
            }
        }
        .accessibilityIdentifier("create-specific-step")
    }
}

private struct HifiCreatePickupStep: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
            HifiSectionHeader(title: "픽업 스팟", trailing: viewModel.showingMapPickup ? "리스트" : "지도") {
                viewModel.showingMapPickup.toggle()
            }

            if viewModel.showingMapPickup {
                RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous)
                    .fill(UniTTColor.Background.surface)
                    .frame(height: 220)
                    .overlay {
                        VStack(spacing: UniTTSpacing.Stack.snug) {
                            Image(systemName: "map")
                                .font(.system(size: 36))
                            Text("학교 등록 스팟 지도")
                                .font(UniTTTypography.labelMedium)
                        }
                        .foregroundStyle(UniTTColor.Text.secondary)
                    }
                    .accessibilityIdentifier("pickup-map-view")
            } else {
                VStack(spacing: UniTTSpacing.Stack.snug) {
                    ForEach(viewModel.pickupSpots, id: \.self) { spot in
                        Button {
                            viewModel.createPickup = spot
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: UniTTSpacing.x4) {
                                    Text(spot)
                                        .font(UniTTTypography.bodyMedium.weight(.semibold))
                                    Text("평일 09-22시 · 학교 사전 등록 스팟")
                                        .font(UniTTTypography.labelSmall)
                                        .foregroundStyle(UniTTColor.Text.secondary)
                                }
                                Spacer()
                                Image(systemName: viewModel.createPickup == spot ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(viewModel.createPickup == spot ? UniTTColor.Brand.primary : UniTTColor.Text.tertiary)
                            }
                            .padding(UniTTSpacing.Inset.comfortable)
                            .primaryCard()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct HifiCreatePreviewStep: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
            HifiHeaderTitle(title: "등록 전에\n한 번 더 확인해 주세요", subtitle: "미리보기는 상품 상세 화면과 같은 정보 순서로 보여요.")
            HifiListingCard(
                listing: MockListing(
                    id: "preview",
                    title: viewModel.createTitle,
                    category: viewModel.createCategory,
                    price: viewModel.createPrice.contains("원") ? viewModel.createPrice : "\(viewModel.createPrice)원",
                    spot: viewModel.createPickup,
                    time: "방금",
                    status: .listed,
                    description: viewModel.createDescription,
                    seller: "관악김학생",
                    isMine: true
                )
            )
            HifiNoticeRow(title: "서버 검수 통과 후 피드에 공개돼요", subtitle: "금지 물품이나 외부 거래 유도는 등록이 거절될 수 있어요.", style: .brand)
        }
    }
}

private struct HifiCreateDoneScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: UniTTSpacing.Stack.relaxed) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 62, weight: .semibold))
                .foregroundStyle(UniTTColor.State.success)
            Text("판매글이 등록됐어요")
                .font(UniTTTypography.heading1)
            Text("내 판매글 보기 또는 홈으로 이동할 수 있어요.")
                .font(UniTTTypography.bodyMedium)
                .foregroundStyle(UniTTColor.Text.secondary)
                .multilineTextAlignment(.center)
            Button("내 판매글 보기") {
                viewModel.route = .history
            }
            .buttonStyle(HifiSecondaryButtonStyle())
            Button("홈으로") {
                viewModel.resetCreateFlow()
            }
            .buttonStyle(HifiPrimaryButtonStyle())
            .accessibilityIdentifier("create-done-home")
            Spacer()
        }
        .padding(UniTTSpacing.Gutter.page)
        .accessibilityIdentifier("create-done-screen")
    }
}

private struct HifiChatListScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                HifiSectionHeader(title: "채팅", trailing: "알림") {
                    viewModel.notificationTab = .chat
                    viewModel.route = .notifications
                }

                if viewModel.chats.isEmpty {
                    HifiEmptyState(systemImage: "bubble.left", title: "아직 채팅이 없어요", subtitle: "관심 있는 매물에서 채팅을 시작해 보세요.", actionTitle: "매물 둘러보기") {
                        viewModel.resetToHome()
                    }
                } else {
                    VStack(spacing: UniTTSpacing.Stack.normal) {
                        ForEach(viewModel.chats) { chat in
                            Button {
                                viewModel.route = .chatRoom(chat)
                            } label: {
                                HifiChatRow(chat: chat)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("chat-row-\(chat.id)")
                        }
                    }
                }
            }
            .padding(UniTTSpacing.Gutter.page)
        }
        .background(UniTTColor.Background.page)
        .accessibilityIdentifier("chat-list-screen")
    }
}

private struct HifiChatRoomScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel
    let chat: MockChat

    var body: some View {
        VStack(spacing: 0) {
            HifiTopBar(title: chat.name, backAction: { viewModel.route = .main })

            ScrollView {
                VStack(spacing: UniTTSpacing.Stack.normal) {
                    HifiProductMiniBar(title: chat.listingTitle, status: viewModel.tradeStatus)

                    HifiMessageBubble(text: "안녕하세요. 아직 판매 중인가요?", mine: true)
                    HifiMessageBubble(text: "네 가능해요. 정문에서 거래할 수 있어요.", mine: false)
                    HifiMeetupProposalCard()
                    HifiMessageBubble(text: chat.lastMessage, mine: false)

                    if viewModel.showingChatActions {
                        VStack(spacing: UniTTSpacing.Stack.snug) {
                            Button("약속 잡기") {
                                viewModel.showingAppointmentSheet = true
                                viewModel.showingChatActions = false
                            }
                            .buttonStyle(HifiSecondaryButtonStyle())
                            .accessibilityIdentifier("appointment-suggest-button")

                            Button("거래 상태 보기") {
                                viewModel.route = .tradePanel
                            }
                            .buttonStyle(HifiSecondaryButtonStyle())

                            Button("신고") {
                                viewModel.startReport()
                                viewModel.reportTarget = .chat
                            }
                            .buttonStyle(HifiSecondaryButtonStyle())
                        }
                        .accessibilityIdentifier("chat-action-menu")
                    }
                }
                .padding(UniTTSpacing.Gutter.page)
                .padding(.bottom, UniTTSpacing.x24)
            }

            HStack(spacing: UniTTSpacing.Inline.snug) {
                Button {
                    viewModel.showingChatActions.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: UniTTSize.touchMinimum, height: UniTTSize.touchMinimum)
                }
                .foregroundStyle(UniTTColor.Brand.primary)
                .accessibilityIdentifier("appointment-menu-button")

                Text("메시지를 입력하세요")
                    .font(UniTTTypography.bodyMedium)
                    .foregroundStyle(UniTTColor.Text.tertiary)
                    .frame(maxWidth: .infinity, minHeight: UniTTSize.inputHeight, alignment: .leading)
                    .padding(.horizontal, UniTTSpacing.Inset.cozy)
                    .background(UniTTColor.Background.surface)
                    .clipShape(Capsule())

                Button {
                    viewModel.blockCurrentUser()
                } label: {
                    Image(systemName: "person.crop.circle.badge.xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: UniTTSize.touchMinimum, height: UniTTSize.touchMinimum)
                }
                .foregroundStyle(UniTTColor.State.danger)
                .accessibilityIdentifier("block-user-button")
            }
            .padding(.horizontal, UniTTSpacing.Gutter.page)
            .padding(.vertical, UniTTSpacing.Stack.snug)
            .background(UniTTColor.Background.elevated)
            .overlay(alignment: .top) {
                Rectangle().fill(UniTTColor.Border.default).frame(height: 1)
            }
        }
        .background(UniTTColor.Background.page)
        .accessibilityIdentifier("chat-room-screen")
    }
}

private struct HifiTradePanelScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            HifiTopBar(title: "거래 상태", backAction: { viewModel.route = .main })

            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                    HifiStatusFlow(status: viewModel.tradeStatus)
                    HifiNoticeRow(title: "예약 상태가 변경되면 채팅에 시스템 메시지가 남아요", subtitle: "상태 전환은 거래 히스토리로 기록됩니다.", style: .brand)

                    VStack(alignment: .leading, spacing: UniTTSpacing.Stack.normal) {
                        HifiTimelineRow(title: "채팅 시작", subtitle: "오늘 17:12", active: true)
                        HifiTimelineRow(title: "약속 제안", subtitle: "정문 · 오늘 18:00", active: true)
                        HifiTimelineRow(title: "예약중", subtitle: "상대 수락 대기", active: viewModel.tradeStatus != .listed)
                        HifiTimelineRow(title: "거래 완료", subtitle: "완료 후 후기 작성 가능", active: viewModel.tradeStatus == .completed)
                    }

                    Button("거래 완료") {
                        viewModel.completeTrade()
                    }
                    .buttonStyle(HifiPrimaryButtonStyle())
                    .accessibilityIdentifier("trade-complete-button")

                    Button("후기 작성") {
                        viewModel.route = .review
                    }
                    .buttonStyle(HifiSecondaryButtonStyle())

                    Button("분쟁 신고") {
                        viewModel.disputeTrade()
                    }
                    .buttonStyle(HifiDangerButtonStyle())
                    .accessibilityIdentifier("trade-dispute-button")
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .background(UniTTColor.Background.page)
        .accessibilityIdentifier("trade-panel-screen")
    }
}

private struct HifiReviewScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            HifiTopBar(title: "후기 작성", backAction: { viewModel.route = .tradePanel })
            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                    HifiHeaderTitle(title: "이번 거래는\n어땠나요?", subtitle: "후기는 거래당 한 번만 남길 수 있어요.")

                    HStack(spacing: UniTTSpacing.Inline.snug) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                viewModel.reviewRating = star
                            } label: {
                                Image(systemName: star <= viewModel.reviewRating ? "star.fill" : "star")
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundStyle(UniTTColor.State.warning)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("review-star-\(star)")
                        }
                    }

                    HStack(spacing: UniTTSpacing.Inline.snug) {
                        HifiFilterChip(title: "시간을 잘 지켰어요")
                        HifiFilterChip(title: "상품 상태가 설명대로였어요")
                    }

                    HifiFormField(title: "후기", text: $viewModel.reviewComment, placeholder: "후기를 남겨 주세요")

                    Button("후기 등록") {
                        viewModel.resetToHome()
                    }
                    .buttonStyle(HifiPrimaryButtonStyle(enabled: viewModel.canSubmitReview))
                    .disabled(!viewModel.canSubmitReview)
                    .accessibilityIdentifier("review-submit-button")
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .accessibilityIdentifier("review-screen")
    }
}

private struct HifiReportFlowScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            HifiTopBar(title: "신고", backAction: { viewModel.route = .main })

            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                    HifiReportProgress(step: viewModel.reportStep)

                    switch viewModel.reportStep {
                    case .target:
                        HifiHeaderTitle(title: "무엇을\n신고하시나요?", subtitle: "진입 위치에 따라 기본 대상이 자동 선택돼요.")
                        ForEach(ReportTarget.allCases) { target in
                            Button {
                                viewModel.reportTarget = target
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: UniTTSpacing.x4) {
                                        Text("\(target.rawValue) 신고")
                                            .font(UniTTTypography.bodyMedium.weight(.semibold))
                                        Text("운영팀 검토를 위해 대상 정보가 함께 제출돼요.")
                                            .font(UniTTTypography.labelSmall)
                                            .foregroundStyle(UniTTColor.Text.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: viewModel.reportTarget == target ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(viewModel.reportTarget == target ? UniTTColor.State.danger : UniTTColor.Text.tertiary)
                                }
                                .padding(UniTTSpacing.Inset.comfortable)
                                .primaryCard()
                            }
                            .buttonStyle(.plain)
                        }
                    case .reason:
                        HifiHeaderTitle(title: "신고 사유를\n선택해 주세요", subtitle: "가장 가까운 사유를 하나만 선택해 주세요.")
                        ForEach(viewModel.reportReasons, id: \.self) { reason in
                            Button {
                                viewModel.reportReason = reason
                            } label: {
                                HStack {
                                    Text(reason)
                                        .font(UniTTTypography.bodyMedium.weight(.semibold))
                                    Spacer()
                                    Image(systemName: viewModel.reportReason == reason ? "checkmark.circle.fill" : "circle")
                                }
                                .foregroundStyle(viewModel.reportReason == reason ? UniTTColor.State.danger : UniTTColor.Text.primary)
                                .padding(UniTTSpacing.Inset.comfortable)
                                .primaryCard()
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier(reason == "노쇼/약속 불이행" ? "report-reason-noshow" : "report-reason-\(reason)")
                        }
                    case .detail:
                        HifiHeaderTitle(title: "상세 내용을\n입력해 주세요", subtitle: "신고자 정보는 상대방에게 공개되지 않아요.")
                        HifiFormField(title: "상세 내용", text: $viewModel.reportDetail, placeholder: "10자 이상 입력")
                        HifiNoticeRow(title: "채팅 캡처나 매물 사진을 첨부하면 검토가 빨라져요", subtitle: "프로토타입에서는 첨부 UI만 표시합니다.", style: .danger)
                    case .done:
                        VStack(spacing: UniTTSpacing.Stack.relaxed) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 62, weight: .semibold))
                                .foregroundStyle(UniTTColor.State.danger)
                            Text("신고가 접수되었어요")
                                .font(UniTTTypography.heading1)
                            HifiKeyValueRow(key: "신고 번호", value: "RPT-2026-18472")
                            HifiKeyValueRow(key: "대상", value: "\(viewModel.reportTarget.rawValue) · \(viewModel.reportReason)")
                            Button("내 신고 내역") {
                                viewModel.notificationTab = .system
                                viewModel.route = .notifications
                            }
                            .buttonStyle(HifiPrimaryButtonStyle())
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("report-done-screen")
                    }

                    if viewModel.reportStep != .done {
                        if viewModel.reportStep == .detail {
                            Button("신고 제출") {
                                viewModel.nextReportStep()
                            }
                            .buttonStyle(HifiDangerButtonStyle())
                            .disabled(!viewModel.canContinueReport)
                            .accessibilityIdentifier("report-next")
                        } else {
                            Button("다음") {
                                viewModel.nextReportStep()
                            }
                            .buttonStyle(HifiPrimaryButtonStyle(enabled: viewModel.canContinueReport))
                            .disabled(!viewModel.canContinueReport)
                            .accessibilityIdentifier("report-next")
                        }
                    }
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .background(UniTTColor.Background.page)
        .accessibilityIdentifier("report-flow-screen")
    }
}

private struct HifiBlockListScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            HifiTopBar(title: "차단 사용자", backAction: { viewModel.route = .main })
            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.normal) {
                    if viewModel.showingBlockToast {
                        HifiNoticeRow(title: "사용자를 차단했어요", subtitle: "5초 안에 실행 취소할 수 있어요.", style: .danger)
                            .accessibilityIdentifier("block-toast")
                    }

                    Text("차단된 사용자와는 서로 판매글과 채팅이 보이지 않아요.")
                        .font(UniTTTypography.bodySmall)
                        .foregroundStyle(UniTTColor.Text.secondary)
                        .lineSpacing(3)

                    ForEach(viewModel.blockedUsers, id: \.self) { user in
                        HStack(spacing: UniTTSpacing.Inline.normal) {
                            Circle()
                                .fill(UniTTColor.Background.surface)
                                .frame(width: 42, height: 42)
                                .overlay(Text(String(user.prefix(1))).font(UniTTTypography.labelMedium))
                            VStack(alignment: .leading, spacing: UniTTSpacing.x4) {
                                Text(user).font(UniTTTypography.bodyMedium.weight(.semibold))
                                Text("차단됨").font(UniTTTypography.labelSmall).foregroundStyle(UniTTColor.Text.secondary)
                            }
                            Spacer()
                            Button("해제") {}
                                .font(UniTTTypography.labelSmall.weight(.semibold))
                                .foregroundStyle(UniTTColor.Brand.primary)
                        }
                        .padding(UniTTSpacing.Inset.comfortable)
                        .primaryCard()
                    }
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .accessibilityIdentifier("block-list-screen")
    }
}

private struct HifiNotificationsScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel
    @State private var showsSettings = false

    var body: some View {
        VStack(spacing: 0) {
            HifiTopBar(
                title: showsSettings ? "알림 설정" : "알림",
                backAction: { viewModel.route = .main },
                rightSystemImage: showsSettings ? nil : "gearshape",
                rightAction: { showsSettings = true }
            )

            if showsSettings {
                VStack(spacing: UniTTSpacing.Stack.normal) {
                    HifiToggleRow(title: "채팅 메시지", subtitle: "새 채팅 메시지", isOn: .constant(true))
                    HifiToggleRow(title: "거래 상태", subtitle: "예약·완료·대기열 변경", isOn: $viewModel.pushEnabled)
                    HifiToggleRow(title: "신고 처리 결과", subtitle: "내 신고 건의 처리 상태 변경", isOn: .constant(true))
                    HifiToggleRow(title: "마케팅", subtitle: "이벤트와 추천 매물", isOn: $viewModel.marketingEnabled)
                    Spacer()
                }
                .padding(UniTTSpacing.Gutter.page)
                .accessibilityIdentifier("notification-settings-screen")
            } else {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.normal) {
                    HStack(spacing: UniTTSpacing.Inline.snug) {
                        ForEach(NotificationTab.allCases) { tab in
                            HifiChip(title: tab.rawValue, selected: viewModel.notificationTab == tab) {
                                viewModel.notificationTab = tab
                            }
                        }
                    }
                    .padding(.horizontal, UniTTSpacing.Gutter.page)
                    .padding(.top, UniTTSpacing.Stack.normal)

                    if viewModel.visibleNotifications.isEmpty {
                        HifiEmptyState(systemImage: "bell", title: "새 알림이 없어요", subtitle: "거래·채팅·시스템 알림이 여기 모여요.", actionTitle: nil, action: nil)
                            .padding(UniTTSpacing.Gutter.page)
                            .accessibilityIdentifier("notifications-empty-screen")
                    } else {
                        ScrollView {
                            VStack(spacing: UniTTSpacing.Stack.normal) {
                                ForEach(viewModel.visibleNotifications) { notification in
                                    HifiNotificationRow(notification: notification)
                                }
                            }
                            .padding(UniTTSpacing.Gutter.page)
                        }
                    }
                }
            }
        }
        .background(UniTTColor.Background.page)
        .accessibilityIdentifier("notifications-screen")
    }
}

private struct HifiMyPageScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                HStack {
                    HStack(spacing: UniTTSpacing.Inline.normal) {
                        Circle()
                            .fill(UniTTColor.Brand.primarySubtle)
                            .frame(width: 56, height: 56)
                            .overlay(Text("관악").font(UniTTTypography.labelMedium).foregroundStyle(UniTTColor.Brand.primary))
                        VStack(alignment: .leading, spacing: UniTTSpacing.x4) {
                            Text("관악김학생")
                                .font(UniTTTypography.heading2)
                            Text("서울대학교 인증")
                                .font(UniTTTypography.labelSmall)
                                .foregroundStyle(UniTTColor.Brand.primary)
                        }
                    }
                    Spacer()
                    Button {
                        viewModel.route = .settings
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: UniTTSize.touchMinimum, height: UniTTSize.touchMinimum)
                    }
                    .foregroundStyle(UniTTColor.Text.primary)
                    .accessibilityIdentifier("my-settings-button")
                }

                HStack(spacing: UniTTSpacing.Inline.snug) {
                    HifiTrustMetric(value: "12", label: "판매")
                    HifiTrustMetric(value: "8", label: "구매")
                    HifiTrustMetric(value: "4.8", label: "평점")
                }

                HifiNavRow(title: "내 판매/구매 내역", subtitle: "등록 글과 거래 완료 내역") {
                    viewModel.route = .history
                }
                HifiNavRow(title: "차단 사용자", subtitle: "차단 목록 관리") {
                    viewModel.route = .blockList
                }
                HifiNavRow(title: "알림 센터", subtitle: "거래·채팅·시스템") {
                    viewModel.route = .notifications
                }
            }
            .padding(UniTTSpacing.Gutter.page)
        }
        .background(UniTTColor.Background.page)
        .accessibilityIdentifier("my-page-screen")
    }
}

private struct HifiHistoryScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            HifiTopBar(title: "내역", backAction: { viewModel.route = .main })
            ScrollView {
                VStack(spacing: UniTTSpacing.Stack.normal) {
                    ForEach(viewModel.listings.filter { $0.isMine }) { listing in
                        HifiListingCard(listing: listing)
                    }
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .accessibilityIdentifier("history-screen")
    }
}

private struct HifiSettingsScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            HifiTopBar(title: "설정", backAction: { viewModel.route = .main })
            ScrollView {
                VStack(spacing: UniTTSpacing.Stack.loose) {
                    HifiToggleRow(title: "푸시 알림", subtitle: "거래와 채팅 알림", isOn: $viewModel.pushEnabled)
                    HifiToggleRow(title: "마케팅 정보 수신", subtitle: "이벤트와 추천 매물", isOn: $viewModel.marketingEnabled)
                    HifiNavRow(title: "회원 탈퇴", subtitle: "탈퇴 안내 보기", danger: true) {
                        viewModel.route = .withdraw
                    }
                    Button("로그아웃") {
                        viewModel.requestLogout()
                    }
                    .buttonStyle(HifiDangerButtonStyle())
                    .accessibilityIdentifier("settings-logout-button")
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .accessibilityIdentifier("settings-screen")
    }
}

private struct HifiWithdrawScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            HifiTopBar(title: "탈퇴 안내", backAction: { viewModel.route = .settings })
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                HifiHeaderTitle(title: "탈퇴 전\n확인해 주세요", subtitle: "진행 중인 거래가 있으면 먼저 정리해야 해요.")
                HifiNoticeRow(title: "거래 기록은 분쟁 대응을 위해 보관될 수 있어요", subtitle: "프로토타입에서는 실제 탈퇴가 실행되지 않습니다.", style: .danger)
                Spacer()
            }
            .padding(UniTTSpacing.Gutter.page)
        }
        .accessibilityIdentifier("withdraw-screen")
    }
}

private struct HifiAppointmentSheet: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
            HifiHeaderTitle(title: "약속을 제안해요", subtitle: "날짜, 시간대, 픽업 스팟을 선택해 채팅에 카드로 보낼 수 있어요.")
            HStack(spacing: UniTTSpacing.Inline.snug) {
                HifiFilterChip(title: "오늘")
                HifiFilterChip(title: "내일")
                HifiFilterChip(title: "주말")
            }
            HStack(spacing: UniTTSpacing.Inline.snug) {
                HifiFilterChip(title: "오전")
                HifiFilterChip(title: "오후")
                HifiFilterChip(title: "저녁")
            }
            HifiNoticeRow(title: "정문 · 오늘 18:00", subtitle: "판매글에 등록된 스팟 · 평일 09-22시", style: .brand)
            Button("제안 보내기") {
                viewModel.showingAppointmentSheet = false
                viewModel.route = .tradePanel
            }
            .buttonStyle(HifiPrimaryButtonStyle())
            .accessibilityIdentifier("appointment-submit-button")
        }
        .padding(UniTTSpacing.Inset.loose)
    }
}

private struct HifiBottomTabBar: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(UserTab.allCases) { tab in
                Button {
                    viewModel.openTab(tab)
                } label: {
                    VStack(spacing: UniTTSpacing.x4) {
                        Image(systemName: tab.systemImageName)
                            .font(.system(size: tab == .create ? 24 : 18, weight: .semibold))
                        Text(tab.rawValue)
                            .font(UniTTTypography.labelSmall)
                    }
                    .foregroundStyle(viewModel.activeTab == tab ? UniTTColor.Brand.primary : UniTTColor.Text.secondary)
                    .frame(maxWidth: .infinity, minHeight: UniTTSize.tabbarHeight)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("tab-\(tab.rawValue)")
            }
        }
        .background(UniTTColor.Background.elevated)
        .overlay(alignment: .top) {
            Rectangle().fill(UniTTColor.Border.default).frame(height: 1)
        }
    }
}

private struct HifiTopBar: View {
    let title: String
    let backAction: (() -> Void)?
    let rightSystemImage: String?
    let rightAction: (() -> Void)?

    init(
        title: String,
        backAction: (() -> Void)? = nil,
        rightSystemImage: String? = nil,
        rightAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.backAction = backAction
        self.rightSystemImage = rightSystemImage
        self.rightAction = rightAction
    }

    var body: some View {
        HStack {
            if let backAction {
                Button(action: backAction) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: UniTTSize.touchMinimum, height: UniTTSize.touchMinimum)
                }
                .foregroundStyle(UniTTColor.Text.primary)
                .accessibilityIdentifier("top-back-button")
            } else {
                Color.clear.frame(width: UniTTSize.touchMinimum, height: UniTTSize.touchMinimum)
            }

            Spacer()

            Text(title)
                .font(UniTTTypography.heading3)
                .foregroundStyle(UniTTColor.Text.primary)

            Spacer()

            if let rightSystemImage, let rightAction {
                Button(action: rightAction) {
                    Image(systemName: rightSystemImage)
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: UniTTSize.touchMinimum, height: UniTTSize.touchMinimum)
                }
                .foregroundStyle(UniTTColor.Text.primary)
                .accessibilityIdentifier(rightSystemImage == "gearshape" ? "top-settings-button" : "top-right-button")
            } else {
                Color.clear.frame(width: UniTTSize.touchMinimum, height: UniTTSize.touchMinimum)
            }
        }
        .padding(.horizontal, UniTTSpacing.x6)
        .background(UniTTColor.Background.elevated)
        .overlay(alignment: .bottom) {
            Rectangle().fill(UniTTColor.Border.default).frame(height: 1)
        }
    }
}

private struct HifiHeaderTitle: View {
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

private struct HifiListingCard: View {
    let listing: MockListing

    var body: some View {
        HStack(alignment: .top, spacing: UniTTSpacing.Inline.normal) {
            RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
                .fill(UniTTColor.Background.surface)
                .frame(width: 86, height: 86)
                .overlay(Image(systemName: "photo").foregroundStyle(UniTTColor.Text.tertiary))

            VStack(alignment: .leading, spacing: UniTTSpacing.x6) {
                HStack {
                    Text(listing.category)
                        .font(UniTTTypography.labelSmall)
                        .foregroundStyle(UniTTColor.Brand.primary)
                    Spacer()
                    HifiStatusChip(status: listing.status)
                }

                Text(listing.title)
                    .font(UniTTTypography.bodyMedium.weight(.semibold))
                    .foregroundStyle(UniTTColor.Text.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text("\(listing.spot) · \(listing.time)")
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(UniTTColor.Text.secondary)

                Text(listing.price)
                    .font(UniTTTypography.heading3)
                    .foregroundStyle(listing.price.contains("무료") ? UniTTColor.Brand.primary : UniTTColor.Text.primary)
            }
        }
        .padding(UniTTSpacing.Inset.comfortable)
        .primaryCard()
    }
}

private struct HifiStatusChip: View {
    let status: ListingStatus

    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, UniTTSpacing.x8)
            .padding(.vertical, UniTTSpacing.x4)
            .background(background)
            .clipShape(Capsule())
    }

    private var background: Color {
        switch status {
        case .listed:
            return UniTTColor.Chip.Listed.bg
        case .reserved:
            return UniTTColor.Chip.Reserved.bg
        case .completed:
            return UniTTColor.Chip.Completed.bg
        case .canceled:
            return UniTTColor.Chip.Canceled.bg
        case .disputed:
            return UniTTColor.Chip.Disputed.bg
        }
    }

    private var foreground: Color {
        switch status {
        case .listed:
            return UniTTColor.Chip.Listed.ink
        case .reserved:
            return UniTTColor.Chip.Reserved.ink
        case .completed:
            return UniTTColor.Chip.Completed.ink
        case .canceled:
            return UniTTColor.Chip.Canceled.ink
        case .disputed:
            return UniTTColor.Chip.Disputed.ink
        }
    }
}

private struct HifiChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(UniTTTypography.labelMedium)
                .foregroundStyle(selected ? UniTTColor.Brand.primary : UniTTColor.Text.primary)
                .padding(.horizontal, UniTTSpacing.x12)
                .frame(height: 34)
                .background(selected ? UniTTColor.Brand.primarySubtle : UniTTColor.Background.elevated)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(selected ? UniTTColor.Brand.primary : UniTTColor.Border.default, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private struct HifiFilterChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(UniTTTypography.labelSmall)
            .foregroundStyle(UniTTColor.Brand.primaryPressed)
            .padding(.horizontal, UniTTSpacing.x10)
            .frame(height: 28)
            .background(UniTTColor.Brand.primarySubtle)
            .clipShape(Capsule())
    }
}

private struct HifiSectionHeader: View {
    let title: String
    let trailing: String?
    let action: (() -> Void)?

    init(title: String, trailing: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.trailing = trailing
        self.action = action
    }

    var body: some View {
        HStack {
            Text(title)
                .font(UniTTTypography.heading3)
                .foregroundStyle(UniTTColor.Text.primary)
            Spacer()
            if let trailing {
                Button(trailing) {
                    action?()
                }
                .font(UniTTTypography.labelSmall.weight(.semibold))
                .foregroundStyle(UniTTColor.Brand.primary)
                .disabled(action == nil)
            }
        }
    }
}

private struct HifiEmptyState: View {
    let systemImage: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?

    var body: some View {
        VStack(spacing: UniTTSpacing.Stack.normal) {
            Image(systemName: systemImage)
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(UniTTColor.Text.tertiary)
            Text(title)
                .font(UniTTTypography.heading3)
                .foregroundStyle(UniTTColor.Text.primary)
            Text(subtitle)
                .font(UniTTTypography.bodySmall)
                .foregroundStyle(UniTTColor.Text.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(HifiPrimaryButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(UniTTSpacing.Inset.loose)
        .primaryCard()
    }
}

private struct HifiSuggestionRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.normal) {
            Image(systemName: "clock")
                .foregroundStyle(UniTTColor.Brand.primary)
            VStack(alignment: .leading, spacing: UniTTSpacing.x4) {
                Text(title)
                    .font(UniTTTypography.bodyMedium.weight(.semibold))
                    .foregroundStyle(UniTTColor.Text.primary)
                Text(subtitle)
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(UniTTColor.Text.secondary)
            }
            Spacer()
        }
        .padding(UniTTSpacing.Inset.comfortable)
        .primaryCard()
    }
}

private enum HifiNoticeStyle {
    case brand
    case warning
    case danger
}

private struct HifiNoticeRow: View {
    let title: String
    let subtitle: String
    let style: HifiNoticeStyle

    var body: some View {
        HStack(alignment: .top, spacing: UniTTSpacing.Inline.snug) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(ink)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: UniTTSpacing.x4) {
                Text(title)
                    .font(UniTTTypography.bodySmall.weight(.semibold))
                    .foregroundStyle(UniTTColor.Text.primary)
                Text(subtitle)
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(UniTTColor.Text.secondary)
                    .lineSpacing(3)
            }
        }
        .padding(UniTTSpacing.Inset.cozy)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
    }

    private var icon: String {
        switch style {
        case .brand:
            return "info.circle.fill"
        case .warning:
            return "clock.badge.exclamationmark.fill"
        case .danger:
            return "exclamationmark.triangle.fill"
        }
    }

    private var bg: Color {
        switch style {
        case .brand:
            return UniTTColor.Brand.primarySubtle
        case .warning:
            return UniTTColor.State.warningBg
        case .danger:
            return UniTTColor.State.dangerBg
        }
    }

    private var ink: Color {
        switch style {
        case .brand:
            return UniTTColor.Brand.primary
        case .warning:
            return UniTTColor.State.warningText
        case .danger:
            return UniTTColor.State.danger
        }
    }
}

private struct HifiSellerCard: View {
    let name: String
    let isMine: Bool

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.normal) {
            Circle()
                .fill(UniTTColor.Brand.primarySubtle)
                .frame(width: 46, height: 46)
                .overlay(Text(String(name.prefix(1))).font(UniTTTypography.labelMedium).foregroundStyle(UniTTColor.Brand.primary))
            VStack(alignment: .leading, spacing: UniTTSpacing.x4) {
                Text(isMine ? "내가 올린 글" : name)
                    .font(UniTTTypography.bodyMedium.weight(.semibold))
                Text("서울대학교 인증 · 거래 12건")
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(UniTTColor.Text.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(UniTTColor.Brand.primary)
        }
        .padding(UniTTSpacing.Inset.comfortable)
        .primaryCard()
    }
}

private struct HifiTrustMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: UniTTSpacing.x4) {
            Text(value)
                .font(UniTTTypography.heading3)
                .foregroundStyle(UniTTColor.Text.primary)
            Text(label)
                .font(UniTTTypography.labelSmall)
                .foregroundStyle(UniTTColor.Text.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(UniTTSpacing.Inset.cozy)
        .primaryCard()
    }
}

private struct HifiCreateProgress: View {
    let step: CreateStep

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.snug) {
            ForEach(CreateStep.allCases.filter { $0 != .done }, id: \.rawValue) { item in
                Capsule()
                    .fill(item.rawValue <= step.rawValue ? UniTTColor.Brand.primary : UniTTColor.Border.default)
                    .frame(height: 4)
            }
        }
    }
}

private struct HifiPhotoSlot: View {
    let index: Int

    var body: some View {
        RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
            .fill(index == 0 ? UniTTColor.Brand.primarySubtle : UniTTColor.Background.surface)
            .frame(width: 88, height: 88)
            .overlay {
                VStack(spacing: UniTTSpacing.x4) {
                    Image(systemName: index == 0 ? "camera.fill" : "plus")
                    Text(index == 0 ? "대표" : "추가")
                        .font(UniTTTypography.labelSmall)
                }
                .foregroundStyle(index == 0 ? UniTTColor.Brand.primary : UniTTColor.Text.tertiary)
            }
            .overlay(
                RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
                    .stroke(UniTTColor.Border.default, lineWidth: 1)
            )
    }
}

private struct HifiFormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
            Text(title)
                .font(UniTTTypography.labelSmall)
                .foregroundStyle(UniTTColor.Text.secondary)
            TextField(placeholder, text: $text, axis: .vertical)
                .font(UniTTTypography.bodyMedium)
                .lineLimit(1...4)
                .inputChrome(focused: true)
        }
    }
}

private struct HifiChatRow: View {
    let chat: MockChat

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.normal) {
            Circle()
                .fill(UniTTColor.Background.surface)
                .frame(width: 48, height: 48)
                .overlay(Text(String(chat.name.prefix(1))).font(UniTTTypography.labelMedium))

            VStack(alignment: .leading, spacing: UniTTSpacing.x4) {
                HStack {
                    Text(chat.name)
                        .font(UniTTTypography.bodyMedium.weight(chat.unreadCount > 0 ? .bold : .semibold))
                    Spacer()
                    Text(chat.time)
                        .font(UniTTTypography.labelSmall)
                        .foregroundStyle(UniTTColor.Text.secondary)
                }
                Text(chat.listingTitle)
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(UniTTColor.Brand.primary)
                Text(chat.lastMessage)
                    .font(UniTTTypography.bodySmall)
                    .foregroundStyle(UniTTColor.Text.secondary)
            }

            if chat.unreadCount > 0 {
                Text("\(chat.unreadCount)")
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(UniTTColor.Text.onBrand)
                    .frame(width: 22, height: 22)
                    .background(UniTTColor.Brand.primary)
                    .clipShape(Circle())
            }
        }
        .padding(UniTTSpacing.Inset.comfortable)
        .primaryCard()
    }
}

private struct HifiProductMiniBar: View {
    let title: String
    let status: ListingStatus

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.normal) {
            RoundedRectangle(cornerRadius: UniTTRadius.md, style: .continuous)
                .fill(UniTTColor.Background.surface)
                .frame(width: 52, height: 52)
                .overlay(Image(systemName: "photo").foregroundStyle(UniTTColor.Text.tertiary))
            VStack(alignment: .leading, spacing: UniTTSpacing.x4) {
                Text(title)
                    .font(UniTTTypography.bodyMedium.weight(.semibold))
                    .lineLimit(1)
                HifiStatusChip(status: status)
            }
            Spacer()
        }
        .padding(UniTTSpacing.Inset.cozy)
        .primaryCard()
    }
}

private struct HifiMessageBubble: View {
    let text: String
    let mine: Bool

    var body: some View {
        HStack {
            if mine { Spacer(minLength: 44) }
            Text(text)
                .font(UniTTTypography.bodyMedium)
                .foregroundStyle(mine ? UniTTColor.Text.onBrand : UniTTColor.Text.primary)
                .padding(.horizontal, UniTTSpacing.x12)
                .padding(.vertical, UniTTSpacing.x10)
                .background(mine ? UniTTColor.Brand.primary : UniTTColor.Background.surface)
                .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous))
            if !mine { Spacer(minLength: 44) }
        }
    }
}

private struct HifiMeetupProposalCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.snug) {
            Text("약속 제안")
                .font(UniTTTypography.labelSmall)
                .foregroundStyle(UniTTColor.Brand.primary)
            Text("정문 · 오늘 18:00")
                .font(UniTTTypography.bodyMedium.weight(.semibold))
            Text("판매글에 등록된 스팟")
                .font(UniTTTypography.labelSmall)
                .foregroundStyle(UniTTColor.Text.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(UniTTSpacing.Inset.comfortable)
        .background(UniTTColor.Brand.primarySubtle)
        .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
    }
}

private struct HifiStatusFlow: View {
    let status: ListingStatus

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.normal) {
            HStack {
                Text("현재 상태")
                    .font(UniTTTypography.heading3)
                Spacer()
                HifiStatusChip(status: status)
            }

            HStack(spacing: 0) {
                ForEach(["LISTED", "RESERVED", "COMPLETED"], id: \.self) { title in
                    VStack(spacing: UniTTSpacing.x6) {
                        Circle()
                            .fill(isActive(title) ? UniTTColor.Brand.primary : UniTTColor.Border.default)
                            .frame(width: 14, height: 14)
                        Text(title)
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(UniTTColor.Text.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(UniTTSpacing.Inset.comfortable)
        .primaryCard()
    }

    private func isActive(_ title: String) -> Bool {
        switch (title, status) {
        case ("LISTED", _):
            return true
        case ("RESERVED", .reserved), ("RESERVED", .completed), ("RESERVED", .disputed):
            return true
        case ("COMPLETED", .completed), ("COMPLETED", .disputed):
            return true
        default:
            return false
        }
    }
}

private struct HifiTimelineRow: View {
    let title: String
    let subtitle: String
    let active: Bool

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.normal) {
            Circle()
                .fill(active ? UniTTColor.Brand.primary : UniTTColor.Border.default)
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: UniTTSpacing.x4) {
                Text(title).font(UniTTTypography.bodyMedium.weight(.semibold))
                Text(subtitle).font(UniTTTypography.labelSmall).foregroundStyle(UniTTColor.Text.secondary)
            }
            Spacer()
        }
    }
}

private struct HifiReportProgress: View {
    let step: ReportStep

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.snug) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(index <= step.rawValue ? UniTTColor.State.danger : UniTTColor.Border.default)
                    .frame(height: 4)
            }
        }
    }
}

private struct HifiKeyValueRow: View {
    let key: String
    let value: String

    var body: some View {
        HStack {
            Text(key)
                .font(UniTTTypography.labelSmall)
                .foregroundStyle(UniTTColor.Text.secondary)
            Spacer()
            Text(value)
                .font(UniTTTypography.bodySmall.weight(.semibold))
                .foregroundStyle(UniTTColor.Text.primary)
        }
        .padding(UniTTSpacing.Inset.cozy)
        .background(UniTTColor.Background.surface)
        .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.md, style: .continuous))
    }
}

private struct HifiNotificationRow: View {
    let notification: MockNotification

    var body: some View {
        HStack(alignment: .top, spacing: UniTTSpacing.Inline.normal) {
            Circle()
                .fill(UniTTColor.Brand.primary)
                .frame(width: 8, height: 8)
                .padding(.top, UniTTSpacing.x8)
            VStack(alignment: .leading, spacing: UniTTSpacing.x4) {
                Text(notification.title)
                    .font(UniTTTypography.bodyMedium.weight(.semibold))
                Text(notification.body)
                    .font(UniTTTypography.bodySmall)
                    .foregroundStyle(UniTTColor.Text.secondary)
                Text(notification.time)
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(UniTTColor.Text.tertiary)
            }
            Spacer()
        }
        .padding(UniTTSpacing.Inset.comfortable)
        .primaryCard()
    }
}

private struct HifiToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: UniTTSpacing.x4) {
                Text(title).font(UniTTTypography.bodyMedium.weight(.semibold))
                Text(subtitle).font(UniTTTypography.labelSmall).foregroundStyle(UniTTColor.Text.secondary)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(UniTTSpacing.Inset.comfortable)
        .primaryCard()
    }
}

private struct HifiNavRow: View {
    let title: String
    let subtitle: String
    var danger = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: UniTTSpacing.x4) {
                    Text(title)
                        .font(UniTTTypography.bodyMedium.weight(.semibold))
                        .foregroundStyle(danger ? UniTTColor.State.danger : UniTTColor.Text.primary)
                    Text(subtitle)
                        .font(UniTTTypography.labelSmall)
                        .foregroundStyle(UniTTColor.Text.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(UniTTColor.Text.tertiary)
            }
            .padding(UniTTSpacing.Inset.comfortable)
            .primaryCard()
        }
        .buttonStyle(.plain)
    }
}

private struct HifiDangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(UniTTTypography.labelLarge)
            .foregroundStyle(UniTTColor.Text.onBrand)
            .frame(maxWidth: .infinity, minHeight: UniTTSize.ctaHeight)
            .background(configuration.isPressed ? UniTTColor.State.dangerText : UniTTColor.State.danger)
            .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous))
    }
}

#Preview {
    UserHifiAppView()
}
