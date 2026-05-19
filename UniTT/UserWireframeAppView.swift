//
//  UserWireframeAppView.swift
//  UniTT
//
//  Created by Codex on 5/15/26.
//

import SwiftUI

struct UserWireframeAppView: View {
    @StateObject private var viewModel = UserWireframeViewModel()

    var body: some View {
        ZStack {
            UniTTColor.Background.page
                .ignoresSafeArea()

            switch viewModel.route {
            case .main:
                MainTabShell(viewModel: viewModel)
            case .productDetail(let listing):
                ProductDetailScreen(viewModel: viewModel, listing: listing)
            case .report:
                ReportFlowScreen(viewModel: viewModel)
            case .notifications:
                NotificationsScreen(viewModel: viewModel)
            case .blockList:
                BlockListScreen(viewModel: viewModel)
            case .settings:
                SettingsScreen(viewModel: viewModel)
            case .history:
                HistoryScreen(viewModel: viewModel)
            case .chatRoom(let chat):
                ChatRoomScreen(viewModel: viewModel, chat: chat)
            case .tradePanel:
                TradePanelScreen(viewModel: viewModel)
            case .review:
                ReviewScreen(viewModel: viewModel)
            case .withdraw:
                WithdrawScreen(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $viewModel.showingAppointmentSheet) {
            AppointmentSheet(viewModel: viewModel)
                .presentationDetents([.medium])
        }
        .confirmationDialog("거래 액션", isPresented: $viewModel.showingHistoryActions) {
            Button("채팅으로 이동") {
                if let chat = viewModel.chats.first {
                    viewModel.route = .chatRoom(chat)
                }
            }
            Button("거래 관리") {
                viewModel.route = .tradePanel
            }
            Button("예약 취소", role: .destructive) {}
            Button("취소", role: .cancel) {}
        }
        .confirmationDialog("로그아웃", isPresented: $viewModel.showingLogoutDialog) {
            Button("로그아웃", role: .destructive) {}
            Button("취소", role: .cancel) {}
        } message: {
            Text("현재 계정에서 로그아웃할까요?")
        }
    }
}

private struct MainTabShell: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch viewModel.activeTab {
                case .home:
                    HomeFeedScreen(viewModel: viewModel)
                case .search:
                    SearchScreen(viewModel: viewModel)
                case .create:
                    ListingCreateScreen(viewModel: viewModel)
                case .chat:
                    ChatListScreen(viewModel: viewModel)
                case .my:
                    MyPageScreen(viewModel: viewModel)
                }
            }

            BottomTabBar(viewModel: viewModel)
        }
    }
}

private struct HomeFeedScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(
                title: "서울대학교",
                rightSystemImage: "bell",
                rightAction: { viewModel.route = .notifications }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: UniTTSpacing.Inline.snug) {
                            ForEach(viewModel.categories, id: \.self) { category in
                                ChipButton(
                                    title: category,
                                    selected: viewModel.selectedCategory == category
                                ) {
                                    viewModel.selectedCategory = category
                                }
                                .accessibilityIdentifier(category == "교재" ? "category-textbook-button" : "category-\(category)")
                            }
                        }
                        .padding(.horizontal, UniTTSpacing.Gutter.page)
                    }

                    SectionHeader(title: viewModel.selectedCategory == "전체" ? "캠퍼스 최신 거래" : "\(viewModel.selectedCategory) 거래")
                        .padding(.horizontal, UniTTSpacing.Gutter.page)

                    LazyVStack(spacing: UniTTSpacing.Stack.normal) {
                        ForEach(viewModel.visibleListings) { listing in
                            ListingRow(listing: listing) {
                                viewModel.route = .productDetail(listing)
                            }
                        }
                    }
                    .padding(.horizontal, UniTTSpacing.Gutter.page)
                    .padding(.bottom, UniTTSpacing.Stack.loose)
                }
                .padding(.top, UniTTSpacing.Stack.normal)
            }
        }
        .accessibilityIdentifier("user-home-screen")
    }
}

private struct SearchScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "검색")

            VStack(spacing: UniTTSpacing.Stack.normal) {
                HStack(spacing: UniTTSpacing.Inline.snug) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(UniTTColor.Text.secondary)
                    TextField("찾고 싶은 물건을 검색해 보세요", text: $viewModel.searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("search-field")
                }
                .padding(.horizontal, UniTTSpacing.Inset.cozy)
                .frame(height: UniTTSize.inputHeight + 6)
                .background(UniTTColor.Background.surface)
                .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
                        .stroke(UniTTColor.Border.default, lineWidth: 1)
                )

                if viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    RecentSearches(viewModel: viewModel)
                } else {
                    SearchResults(viewModel: viewModel)
                }
            }
            .padding(UniTTSpacing.Gutter.page)

            Spacer()
        }
        .accessibilityIdentifier("search-screen")
    }
}

private struct RecentSearches: View {
    @ObservedObject var viewModel: UserWireframeViewModel
    private let recent = ["자료구조", "에어팟", "미니냉장고", "이산수학", "책상", "일반화학"]

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.normal) {
            SectionHeader(title: "최근 검색어", trailing: "모두 지우기")

            FlexibleChips(items: recent) { item in
                Button {
                    viewModel.searchText = item
                } label: {
                    Text(item)
                }
                .chipStyle(selected: false)
                .accessibilityIdentifier(item == "에어팟" ? "recent-search-airpods" : "recent-search-\(item)")
            }

            SectionHeader(title: "추천 검색")
                .padding(.top, UniTTSpacing.Stack.relaxed)

            VStack(spacing: UniTTSpacing.Stack.snug) {
                SuggestionRow(rank: 1, title: "에어팟", subtitle: "전자기기 · 정문 거래 많음")
                SuggestionRow(rank: 2, title: "자료구조", subtitle: "교재 · 중간고사 시즌")
                SuggestionRow(rank: 3, title: "미니냉장고", subtitle: "자취·기숙사")
            }
        }
    }
}

private struct SearchResults: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.normal) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: UniTTSpacing.Inline.snug) {
                    ChipButton(title: "전체", selected: true) {}
                    ChipButton(title: "전자기기", selected: false) {}
                    ChipButton(title: "자취·기숙사", selected: false) {}
                    ChipButton(title: "10만원 이하", selected: false) {}
                }
            }

            if viewModel.searchResults.isEmpty {
                EmptyStateView(title: "검색 결과가 없어요", subtitle: "다른 키워드로 검색해 보세요.", systemImage: "magnifyingglass")
            } else {
                ForEach(viewModel.searchResults) { listing in
                    ListingRow(listing: listing, accessibilityID: "search-result-\(listing.id)") {
                        viewModel.route = .productDetail(listing)
                    }
                }
            }
        }
    }
}

private struct ProductDetailScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel
    let listing: MockListing
    @State private var ownerVariant = false

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(
                title: "상품 상세",
                backAction: { viewModel.route = .main },
                rightSystemImage: "exclamationmark.bubble",
                rightAction: { viewModel.startReport() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
                    RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous)
                        .fill(UniTTColor.Background.surface)
                        .frame(height: 260)
                        .overlay {
                            VStack(spacing: UniTTSpacing.Stack.snug) {
                                Image(systemName: "photo")
                                    .font(.system(size: 36))
                                Text("상품 사진")
                                    .font(UniTTTypography.labelMedium)
                            }
                            .foregroundStyle(UniTTColor.Text.tertiary)
                        }

                    HStack {
                        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.snug) {
                            Text(listing.title)
                                .font(UniTTTypography.heading1)
                                .foregroundStyle(UniTTColor.Text.primary)
                            HStack {
                                Text(listing.price)
                                    .font(.system(size: 22, weight: .bold))
                                StatusChip(status: listing.status)
                            }
                        }
                        Spacer()
                    }

                    InfoLine(icon: "mappin.and.ellipse", title: listing.spot, subtitle: "\(listing.time) · \(listing.category)")
                    InfoLine(icon: "person.crop.circle", title: listing.seller, subtitle: "서울대학교 인증")

                    Text(listing.description)
                        .font(UniTTTypography.bodyMedium)
                        .foregroundStyle(UniTTColor.Text.primary)
                        .lineSpacing(4)

                    Toggle("본인 글 시점 보기", isOn: $ownerVariant)
                        .font(UniTTTypography.labelMedium)
                        .padding(.top, UniTTSpacing.Stack.normal)
                        .accessibilityIdentifier("owner-variant-toggle")
                }
                .padding(UniTTSpacing.Gutter.page)
                .padding(.bottom, 92)
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: UniTTSpacing.Inline.normal) {
                if ownerVariant || listing.isMine {
                    Button("수정하기") {}
                        .buttonStyle(SecondaryActionButtonStyle())
                    Button("판매완료") {}
                        .buttonStyle(PrimaryActionButtonStyle())
                } else {
                    Button {
                        if let chat = viewModel.chats.first {
                            viewModel.route = .chatRoom(chat)
                        }
                    } label: {
                        Text("채팅하기")
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                    .accessibilityIdentifier("start-chat-button")
                }
            }
            .padding(UniTTSpacing.Gutter.page)
            .background(UniTTColor.Background.page)
        }
        .accessibilityIdentifier("product-detail-screen")
    }
}

private struct ListingCreateScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(
                title: createTitle,
                rightText: viewModel.createStep == .done ? nil : "임시저장",
                rightAction: {}
            )

            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.loose) {
                    CreateProgress(step: viewModel.createStep)

                    switch viewModel.createStep {
                    case .category:
                        CreateCategoryStep(viewModel: viewModel)
                    case .info:
                        CreateInfoStep(viewModel: viewModel)
                    case .textbook:
                        CreateTextbookStep()
                    case .pickup:
                        CreatePickupStep(viewModel: viewModel)
                    case .preview:
                        CreatePreviewStep(viewModel: viewModel)
                    case .done:
                        CreateDoneStep(viewModel: viewModel)
                    }
                }
                .padding(UniTTSpacing.Gutter.page)
                .padding(.bottom, viewModel.createStep == .done ? UniTTSpacing.Stack.loose : 92)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.createStep != .done {
                Button(viewModel.createStep == .preview ? "등록하기" : "다음") {
                    viewModel.nextCreateStep()
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .disabled(viewModel.createStep == .preview && !viewModel.canSubmitListing)
                .padding(UniTTSpacing.Gutter.page)
                .background(UniTTColor.Background.page)
                .accessibilityIdentifier(viewModel.createStep == .preview ? "create-submit" : "create-next")
            }
        }
        .accessibilityIdentifier("listing-create-screen")
    }

    private var createTitle: String {
        switch viewModel.createStep {
        case .category:
            return "카테고리 선택"
        case .info:
            return "정보 입력"
        case .textbook:
            return "교재 정보"
        case .pickup:
            return "픽업 스팟"
        case .preview:
            return "미리보기"
        case .done:
            return "등록 완료"
        }
    }
}

private struct CreateCategoryStep: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
            Text("어떤 물건인가요?")
                .font(UniTTTypography.heading1)
            Text("카테고리에 따라 필요한 정보를 조금 더 받을게요.")
                .font(UniTTTypography.bodySmall)
                .foregroundStyle(UniTTColor.Text.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: UniTTSpacing.Stack.normal) {
                ForEach(["교재", "전자기기", "자취·기숙사", "이사·나눔"], id: \.self) { category in
                    Button {
                        viewModel.createCategory = category
                    } label: {
                        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.snug) {
                            Image(systemName: category == "교재" ? "book.closed" : "shippingbox")
                                .font(.system(size: 22))
                            Text(category)
                                .font(UniTTTypography.heading3)
                            Text(category == "교재" ? "ISBN·과목 정보" : "상태·픽업 정보")
                                .font(UniTTTypography.labelSmall)
                                .foregroundStyle(UniTTColor.Text.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(UniTTSpacing.Inset.comfortable)
                        .primaryCard()
                        .overlay(
                            RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
                                .stroke(viewModel.createCategory == category ? UniTTColor.Brand.primary : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(category == "교재" ? "create-category-textbook" : "create-category-\(category)")
                }
            }
        }
    }
}

private struct CreateInfoStep: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
            FormLabel("사진", trailing: "3 / 10")
            HStack(spacing: UniTTSpacing.Inline.snug) {
                PhotoSlot(systemImage: "plus")
                PhotoSlot(systemImage: "book.closed")
                PhotoSlot(systemImage: "camera")
                PhotoSlot(systemImage: "photo")
            }

            FormTextField(label: "제목", text: $viewModel.createTitle, count: "\(viewModel.createTitle.count) / 40")
            FormTextField(label: "가격", text: $viewModel.createPrice, prefix: "₩")

            FormLabel("상태")
            HStack {
                ForEach(["상", "중", "하"], id: \.self) { condition in
                    ChipButton(title: condition, selected: viewModel.createCondition == condition) {
                        viewModel.createCondition = condition
                    }
                }
            }

            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                FormLabel("설명", trailing: "\(viewModel.createDescription.count) / 1000")
                TextEditor(text: $viewModel.createDescription)
                    .frame(minHeight: 104)
                    .padding(UniTTSpacing.Inset.cozy)
                    .scrollContentBackground(.hidden)
                    .background(UniTTColor.Background.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
                            .stroke(UniTTColor.Border.focus, lineWidth: 1)
                    )
            }
        }
    }
}

private struct CreateTextbookStep: View {
    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
            Text("교재 정보를 더해주세요")
                .font(UniTTTypography.heading1)
            StaticField(label: "ISBN", value: "978-89-7914-914-1")
            StaticField(label: "과목코드", value: "M1522.000900")
            StaticField(label: "교수명", value: "김교수")
            StaticField(label: "학기", value: "2026년 1학기")
            InfoBoxSmall(text: "교재 정보는 검색 필터와 과목별 추천에 사용됩니다.")
        }
    }
}

private struct CreatePickupStep: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
            Text("어디서 만날까요?")
                .font(UniTTTypography.heading1)

            ForEach(["학생회관", "중앙도서관", "정문", "301동", "후문 GS25"], id: \.self) { spot in
                Button {
                    viewModel.createPickup = spot
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                            Text(spot)
                                .font(UniTTTypography.bodyMedium.weight(.semibold))
                            Text(spot == "학생회관" ? "사람이 많고 야간에도 밝아요" : "캠퍼스 내 안전 픽업 스팟")
                                .font(UniTTTypography.labelSmall)
                                .foregroundStyle(UniTTColor.Text.secondary)
                        }
                        Spacer()
                        if viewModel.createPickup == spot {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(UniTTColor.Brand.primary)
                        }
                    }
                    .padding(UniTTSpacing.Inset.comfortable)
                    .primaryCard()
                }
                .buttonStyle(.plain)
            }

            RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous)
                .fill(UniTTColor.Background.surface)
                .frame(height: 160)
                .overlay(Text("지도 미리보기").font(UniTTTypography.labelMedium).foregroundStyle(UniTTColor.Text.secondary))
        }
    }
}

private struct CreatePreviewStep: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
            Text("등록 전 확인해 주세요")
                .font(UniTTTypography.heading1)
            ListingRow(
                listing: MockListing(
                    id: "preview",
                    title: viewModel.createTitle,
                    category: viewModel.createCategory,
                    price: "\(viewModel.createPrice)원",
                    spot: viewModel.createPickup,
                    time: "방금",
                    status: .listed,
                    description: viewModel.createDescription,
                    seller: "관악김학생",
                    isMine: true
                )
            ) {}
            InfoBoxSmall(text: "등록 후에도 내 판매 내역에서 수정하거나 판매완료 처리할 수 있어요.")
        }
    }
}

private struct CreateDoneStep: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: UniTTSpacing.Stack.relaxed) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(UniTTColor.State.success)
            Text("상품 등록 완료")
                .font(UniTTTypography.heading1)
            Text("캠퍼스 피드에 상품이 올라갔어요.")
                .font(UniTTTypography.bodyMedium)
                .foregroundStyle(UniTTColor.Text.secondary)
            Button("홈으로 돌아가기") {
                viewModel.resetCreateFlow()
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .accessibilityIdentifier("create-done-home")
        }
        .frame(maxWidth: .infinity)
        .padding(.top, UniTTSpacing.x48)
        .accessibilityIdentifier("create-done-screen")
    }
}

private struct ChatListScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "채팅")
            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.normal) {
                    ForEach(viewModel.chats) { chat in
                        Button {
                            viewModel.route = .chatRoom(chat)
                        } label: {
                            ChatRow(chat: chat)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("chat-row-\(chat.id)")
                    }

                    EmptyStateView(title: "거래 대기 채팅", subtitle: "거래가 끝난 채팅은 아래로 정리됩니다.", systemImage: "bubble.left.and.bubble.right")
                        .padding(.top, UniTTSpacing.Stack.relaxed)
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .accessibilityIdentifier("chat-list-screen")
    }
}

private struct ChatRoomScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel
    let chat: MockChat

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: chat.name, backAction: { viewModel.route = .main })

            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.normal) {
                ProductMiniBar(title: chat.listingTitle, status: viewModel.tradeStatus)

                ScrollView {
                    VStack(spacing: UniTTSpacing.Stack.normal) {
                        MessageBubble(text: "아직 판매 중인가요?", mine: false)
                        MessageBubble(text: "네 가능해요. 정문 근처 괜찮으세요?", mine: true)
                        MessageBubble(text: "그럼 오늘 6시에 정문에서 뵐게요.", mine: false)
                    }
                    .padding(.vertical, UniTTSpacing.Stack.relaxed)
                }

                HStack(spacing: UniTTSpacing.Inline.snug) {
                    Button {
                        viewModel.showingAppointmentSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .font(.system(size: 28))
                    .accessibilityIdentifier("appointment-menu-button")

                    Text("메시지를 입력하세요")
                        .font(UniTTTypography.bodyMedium)
                        .foregroundStyle(UniTTColor.Text.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, UniTTSpacing.Inset.cozy)
                        .frame(height: UniTTSize.inputHeight + 4)
                        .background(UniTTColor.Background.surface)
                        .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.pill, style: .continuous))

                    Button {
                        viewModel.route = .blockList
                    } label: {
                        Image(systemName: "hand.raised.fill")
                    }
                    .accessibilityLabel("차단")
                    .accessibilityIdentifier("block-user-button")
                }
            }
            .padding(UniTTSpacing.Gutter.page)
        }
        .accessibilityIdentifier("chat-room-screen")
    }
}

private struct TradePanelScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "거래 상태", backAction: { viewModel.route = .main })
            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
                    ProductMiniBar(title: "에어팟 4세대 USB-C", status: viewModel.tradeStatus)

                    VStack(alignment: .leading, spacing: UniTTSpacing.Stack.normal) {
                        TimelineRow(title: "예약됨", subtitle: "오늘 17:12 · 구매자가 예약을 확정했어요", active: true)
                        TimelineRow(title: "약속 예정", subtitle: "오늘 18:00 · 정문", active: viewModel.tradeStatus == .reserved)
                        TimelineRow(title: "거래 완료", subtitle: "거래 완료 후 후기를 남겨요", active: viewModel.tradeStatus == .completed)
                    }
                    .padding(UniTTSpacing.Inset.comfortable)
                    .primaryCard()

                    Button("거래 완료 처리") {
                        viewModel.completeTrade()
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                    .accessibilityIdentifier("trade-complete-button")

                    Button("후기 작성") {
                        viewModel.route = .review
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .accessibilityIdentifier("trade-panel-screen")
    }
}

private struct ReviewScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "거래 후기", backAction: { viewModel.route = .tradePanel })
            ScrollView {
                VStack(spacing: UniTTSpacing.Stack.relaxed) {
                    Text("거래는 어떠셨나요?")
                        .font(UniTTTypography.heading1)

                    HStack(spacing: UniTTSpacing.Inline.snug) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                viewModel.reviewRating = star
                            } label: {
                                Image(systemName: star <= viewModel.reviewRating ? "star.fill" : "star")
                                    .font(.system(size: 32))
                                    .foregroundStyle(UniTTColor.State.warning)
                            }
                            .accessibilityIdentifier("review-star-\(star)")
                        }
                    }

                    TextEditor(text: $viewModel.reviewComment)
                        .frame(minHeight: 120)
                        .padding(UniTTSpacing.Inset.cozy)
                        .scrollContentBackground(.hidden)
                        .background(UniTTColor.Background.surface)
                        .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))

                    Button("후기 등록") {
                        viewModel.route = .main
                        viewModel.activeTab = .chat
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                    .disabled(!viewModel.canSubmitReview)
                    .accessibilityIdentifier("review-submit-button")
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .accessibilityIdentifier("review-screen")
    }
}

private struct ReportFlowScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "신고", backAction: { viewModel.route = .main })
            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
                    CreateProgress(stepNumber: viewModel.reportStep.rawValue + 1, total: 4)

                    switch viewModel.reportStep {
                    case .target:
                        Text("신고 대상을 확인해 주세요")
                            .font(UniTTTypography.heading1)
                        InfoLine(icon: "shippingbox", title: "에어팟 4세대 USB-C", subtitle: "판매자 공대박학생")
                    case .reason:
                        Text("신고 사유를 선택해 주세요")
                            .font(UniTTTypography.heading1)
                        ForEach(viewModel.reportReasons, id: \.self) { reason in
                            Button {
                                viewModel.reportReason = reason
                            } label: {
                                HStack {
                                    Text(reason)
                                    Spacer()
                                    if viewModel.reportReason == reason {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(UniTTColor.Brand.primary)
                                    }
                                }
                                .padding(UniTTSpacing.Inset.comfortable)
                                .primaryCard()
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier(reason == "노쇼/약속 불이행" ? "report-reason-noshow" : "report-reason-\(reason)")
                        }
                    case .detail:
                        Text("상세 내용을 적어 주세요")
                            .font(UniTTTypography.heading1)
                        TextEditor(text: $viewModel.reportDetail)
                            .frame(minHeight: 160)
                            .padding(UniTTSpacing.Inset.cozy)
                            .scrollContentBackground(.hidden)
                            .background(UniTTColor.Background.surface)
                            .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
                    case .done:
                        VStack(spacing: UniTTSpacing.Stack.relaxed) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(UniTTColor.State.danger)
                            Text("신고가 접수됐어요")
                                .font(UniTTTypography.heading1)
                            Text("운영팀이 내용을 확인한 뒤 결과를 알려드릴게요.")
                                .font(UniTTTypography.bodyMedium)
                                .foregroundStyle(UniTTColor.Text.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("report-done-screen")
                    }

                    if viewModel.reportStep != .done {
                        if viewModel.reportStep == .detail {
                            Button("신고 제출") {
                                viewModel.nextReportStep()
                            }
                            .buttonStyle(DangerActionButtonStyle())
                            .disabled(!viewModel.canContinueReport)
                            .accessibilityIdentifier("report-next")
                        } else {
                            Button("다음") {
                                viewModel.nextReportStep()
                            }
                            .buttonStyle(PrimaryActionButtonStyle())
                            .disabled(!viewModel.canContinueReport)
                            .accessibilityIdentifier("report-next")
                        }
                    }
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .accessibilityIdentifier("report-flow-screen")
    }
}

private struct BlockListScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "차단 목록", backAction: { viewModel.route = .main })
            ScrollView {
                VStack(spacing: UniTTSpacing.Stack.normal) {
                    InfoBoxSmall(text: "차단한 사용자의 채팅과 상품은 내 화면에서 숨겨져요.")
                    ForEach(viewModel.blockedUsers, id: \.self) { user in
                        HStack {
                            Circle()
                                .fill(UniTTColor.Background.surface)
                                .frame(width: 40, height: 40)
                                .overlay(Text(String(user.prefix(1))).font(UniTTTypography.labelMedium))
                            VStack(alignment: .leading) {
                                Text(user)
                                    .font(UniTTTypography.bodyMedium.weight(.semibold))
                                Text("2026-05-15 차단")
                                    .font(UniTTTypography.labelSmall)
                                    .foregroundStyle(UniTTColor.Text.secondary)
                            }
                            Spacer()
                            Button("차단 해제") {}
                                .font(UniTTTypography.labelSmall)
                                .buttonStyle(.bordered)
                        }
                        .padding(UniTTSpacing.Inset.cozy)
                        .primaryCard()
                    }
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .accessibilityIdentifier("block-list-screen")
    }
}

private struct NotificationsScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "알림", backAction: { viewModel.route = .main })
            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.normal) {
                    ForEach(viewModel.notifications) { notification in
                        NotificationRow(notification: notification)
                    }

                    SectionHeader(title: "알림 설정")
                        .padding(.top, UniTTSpacing.Stack.relaxed)
                    ToggleRow(title: "푸시 알림", subtitle: "거래·채팅·시스템 알림", isOn: $viewModel.pushEnabled)
                    ToggleRow(title: "마케팅 정보 수신", subtitle: "이벤트·프로모션", isOn: $viewModel.marketingEnabled)
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .accessibilityIdentifier("notifications-screen")
    }
}

private struct MyPageScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(
                title: "마이",
                rightSystemImage: "gearshape",
                rightAction: { viewModel.route = .settings }
            )
            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
                    HStack(spacing: UniTTSpacing.Inline.normal) {
                        Circle()
                            .fill(UniTTColor.Brand.primarySubtle)
                            .frame(width: 64, height: 64)
                            .overlay(Text("관악").font(UniTTTypography.labelMedium).foregroundStyle(UniTTColor.Brand.primary))
                        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                            Text("관악김학생")
                                .font(UniTTTypography.heading2)
                            Text("● 서울대학교 인증")
                                .font(UniTTTypography.labelSmall)
                                .foregroundStyle(UniTTColor.Brand.primary)
                        }
                        Spacer()
                    }
                    .padding(UniTTSpacing.Inset.comfortable)
                    .primaryCard()

                    HStack(spacing: 0) {
                        StatCell(value: "6", label: "판매")
                        StatCell(value: "3", label: "구매")
                        StatCell(value: "4.9", label: "평점")
                    }
                    .primaryCard()

                    SectionHeader(title: "내 거래")
                    NavRow(title: "내 판매 / 구매 내역", trailing: "9건") {
                        viewModel.route = .history
                    }
                    NavRow(title: "알림 센터", trailing: "3건") {
                        viewModel.route = .notifications
                    }
                    NavRow(title: "차단 목록 관리", trailing: "4명") {
                        viewModel.route = .blockList
                    }
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .accessibilityIdentifier("my-page-screen")
    }
}

private struct HistoryScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "내 거래 내역", backAction: { viewModel.route = .main })
            ScrollView {
                VStack(spacing: UniTTSpacing.Stack.normal) {
                    ForEach(viewModel.listings.filter { $0.isMine }) { listing in
                        ListingRow(listing: listing) {
                            viewModel.showingHistoryActions = true
                        }
                    }

                    ForEach(viewModel.listings.prefix(2)) { listing in
                        ListingRow(listing: listing) {
                            viewModel.showingHistoryActions = true
                        }
                    }
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .accessibilityIdentifier("history-screen")
    }
}

private struct SettingsScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "설정", backAction: { viewModel.route = .main })
            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.normal) {
                    SettingsSection("계정")
                    StaticSettingsRow(title: "닉네임", trailing: "관악김학생")
                    StaticSettingsRow(title: "학교 인증", subtitle: "서울대학교 · snu.ac.kr", trailing: "완료")
                    StaticSettingsRow(title: "로그인 방식 관리", subtitle: "Apple · Google", trailing: "")

                    SettingsSection("알림")
                    ToggleRow(title: "푸시 알림", subtitle: "전체 토글", isOn: $viewModel.pushEnabled)
                    ToggleRow(title: "마케팅 정보 수신", subtitle: "이벤트·프로모션", isOn: $viewModel.marketingEnabled)

                    SettingsSection("개인정보 & 보안")
                    StaticSettingsRow(title: "차단 목록 관리", trailing: "4명") {
                        viewModel.route = .blockList
                    }
                    StaticSettingsRow(title: "신고 내역", trailing: "3건") {}
                    StaticSettingsRow(title: "데이터 보존 정책", subtitle: "탈퇴 후 30일 grace · 그 이후 익명화", trailing: "") {}

                    SettingsSection("위험 액션", danger: true)
                    Button {
                        viewModel.requestLogout()
                    } label: {
                        SettingsRowContent(title: "로그아웃", subtitle: nil, trailing: "›", danger: true)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("settings-logout-button")
                    Button {
                        viewModel.route = .withdraw
                    } label: {
                        SettingsRowContent(title: "회원 탈퇴", subtitle: "탈퇴 시 거래 내역 30일 보존 후 영구 삭제", trailing: "›", danger: true)
                    }
                    .buttonStyle(.plain)
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .accessibilityIdentifier("settings-screen")
    }
}

private struct WithdrawScreen: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "회원 탈퇴", backAction: { viewModel.route = .settings })
            ScrollView {
                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
                    Text("탈퇴 전 확인해 주세요")
                        .font(UniTTTypography.heading1)
                    ForEach(["진행 중인 거래와 채팅", "작성한 후기와 평점", "학교 인증 정보", "차단·신고 이력"], id: \.self) { item in
                        HStack {
                            Image(systemName: "xmark.circle")
                                .foregroundStyle(UniTTColor.State.danger)
                            Text(item)
                                .font(UniTTTypography.bodyMedium)
                        }
                        .padding(UniTTSpacing.Inset.cozy)
                        .primaryCard()
                    }
                    Button("홈으로 돌아가기") {
                        viewModel.resetToHome()
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                    Button("탈퇴 진행") {}
                        .buttonStyle(DangerActionButtonStyle())
                }
                .padding(UniTTSpacing.Gutter.page)
            }
        }
        .accessibilityIdentifier("withdraw-screen")
    }
}

private struct AppointmentSheet: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.relaxed) {
            Text("약속을 제안해요")
                .font(UniTTTypography.heading1)
            StaticField(label: "시간", value: "오늘 18:00")
            StaticField(label: "장소", value: "정문")
            StaticField(label: "메모", value: "정문 CU 앞에서 만나요.")
            Button("제안 보내기") {
                viewModel.showingAppointmentSheet = false
                viewModel.route = .tradePanel
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .accessibilityIdentifier("appointment-submit-button")
            Spacer()
        }
        .padding(UniTTSpacing.Inset.loose)
        .background(UniTTColor.Background.page)
    }
}

private struct BottomTabBar: View {
    @ObservedObject var viewModel: UserWireframeViewModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(UserTab.allCases) { tab in
                Button {
                    viewModel.openTab(tab)
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.systemImageName)
                            .font(.system(size: tab == .create ? 24 : 18, weight: .semibold))
                        Text(tab.rawValue)
                            .font(UniTTTypography.labelSmall)
                    }
                    .foregroundStyle(viewModel.activeTab == tab ? UniTTColor.Brand.primary : UniTTColor.Text.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("tab-\(tab.rawValue)")
            }
        }
        .padding(.bottom, UniTTSpacing.Stack.tight)
        .background(UniTTColor.Background.elevated)
        .overlay(alignment: .top) {
            Rectangle().fill(UniTTColor.Border.default).frame(height: 1)
        }
    }
}

private struct AppTopBar: View {
    let title: String
    let backAction: (() -> Void)?
    let rightText: String?
    let rightSystemImage: String?
    let rightAction: (() -> Void)?

    init(
        title: String,
        backAction: (() -> Void)? = nil,
        rightText: String? = nil,
        rightSystemImage: String? = nil,
        rightAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.backAction = backAction
        self.rightText = rightText
        self.rightSystemImage = rightSystemImage
        self.rightAction = rightAction
    }

    var body: some View {
        ZStack {
            Text(title)
                .font(UniTTTypography.heading3)
                .foregroundStyle(UniTTColor.Text.primary)

            HStack {
                if let backAction {
                    Button(action: backAction) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityIdentifier("top-back-button")
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }

                Spacer()

                if let rightText {
                    Button(rightText) {
                        rightAction?()
                    }
                        .font(UniTTTypography.labelMedium)
                        .frame(minWidth: 64, minHeight: 44)
                } else if let rightSystemImage {
                    Button {
                        rightAction?()
                    } label: {
                        Image(systemName: rightSystemImage)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityIdentifier(rightSystemImage == "gearshape" ? "my-settings-button" : "top-right-button")
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, UniTTSpacing.x8)
        }
        .frame(height: UniTTSize.navbarHeight)
        .background(UniTTColor.Background.elevated)
        .overlay(alignment: .bottom) {
            Rectangle().fill(UniTTColor.Border.default).frame(height: 1)
        }
    }
}

private struct ListingRow: View {
    let listing: MockListing
    var accessibilityID: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: UniTTSpacing.Inline.normal) {
                RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
                    .fill(UniTTColor.Background.surface)
                    .frame(width: 82, height: 82)
                    .overlay(Image(systemName: "photo").foregroundStyle(UniTTColor.Text.tertiary))

                VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                    Text(listing.title)
                        .font(UniTTTypography.bodyMedium.weight(.medium))
                        .foregroundStyle(UniTTColor.Text.primary)
                        .lineLimit(2)
                    HStack(spacing: UniTTSpacing.Inline.tight) {
                        StatusChip(status: listing.status)
                        Text(listing.spot)
                        Text("·")
                        Text(listing.time)
                    }
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(UniTTColor.Text.secondary)
                    Text(listing.price)
                        .font(UniTTTypography.heading3)
                        .foregroundStyle(listing.price.contains("무료") ? UniTTColor.Brand.primary : UniTTColor.Text.primary)
                }
                Spacer()
            }
            .padding(UniTTSpacing.Inset.cozy)
            .primaryCard()
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID ?? "product-card-\(listing.id)")
    }
}

private struct StatusChip: View {
    let status: ListingStatus

    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, UniTTSpacing.x6)
            .padding(.vertical, UniTTSpacing.x4)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.sm, style: .continuous))
    }

    private var background: Color {
        switch status {
        case .listed: return UniTTColor.Brand.primarySubtle
        case .reserved: return UniTTColor.State.warning.opacity(0.14)
        case .completed: return UniTTColor.State.success.opacity(0.14)
        case .canceled: return UniTTColor.Chip.Canceled.bg
        case .disputed: return UniTTColor.Chip.Disputed.bg
        }
    }

    private var foreground: Color {
        switch status {
        case .listed: return UniTTColor.Brand.primaryPressed
        case .reserved: return UniTTColor.State.warningText
        case .completed: return UniTTColor.State.successText
        case .canceled: return UniTTColor.Chip.Canceled.ink
        case .disputed: return UniTTColor.Chip.Disputed.ink
        }
    }
}

private struct ChipButton: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .chipStyle(selected: selected)
        }
        .buttonStyle(.plain)
    }
}

private struct SectionHeader: View {
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(title)
                .font(UniTTTypography.labelMedium.weight(.semibold))
                .foregroundStyle(UniTTColor.Text.primary)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(UniTTColor.Text.secondary)
            }
        }
    }
}

private struct FlexibleChips<Content: View>: View {
    let items: [String]
    let content: (String) -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.snug) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: UniTTSpacing.Inline.snug) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }

    private var rows: [[String]] {
        stride(from: 0, to: items.count, by: 3).map {
            Array(items[$0..<min($0 + 3, items.count)])
        }
    }
}

private struct SuggestionRow: View {
    let rank: Int
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.normal) {
            Text("\(rank)")
                .font(UniTTTypography.numeric)
                .foregroundStyle(UniTTColor.Brand.primary)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                Text(title).font(UniTTTypography.bodyMedium.weight(.semibold))
                Text(subtitle).font(UniTTTypography.labelSmall).foregroundStyle(UniTTColor.Text.secondary)
            }
            Spacer()
        }
        .padding(UniTTSpacing.Inset.cozy)
        .primaryCard()
    }
}

private struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(spacing: UniTTSpacing.Stack.snug) {
            Image(systemName: systemImage)
                .font(.system(size: 32))
                .foregroundStyle(UniTTColor.Text.tertiary)
            Text(title)
                .font(UniTTTypography.heading3)
            Text(subtitle)
                .font(UniTTTypography.bodySmall)
                .foregroundStyle(UniTTColor.Text.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(UniTTSpacing.Inset.loose)
        .primaryCard()
    }
}

private struct InfoLine: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.normal) {
            Image(systemName: icon)
                .foregroundStyle(UniTTColor.Brand.primary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                Text(title)
                    .font(UniTTTypography.bodyMedium.weight(.semibold))
                Text(subtitle)
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(UniTTColor.Text.secondary)
            }
            Spacer()
        }
        .padding(UniTTSpacing.Inset.cozy)
        .primaryCard()
    }
}

private struct FormLabel: View {
    let title: String
    let trailing: String?

    init(_ title: String, trailing: String? = nil) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if let trailing {
                Text(trailing)
            }
        }
        .font(UniTTTypography.labelSmall)
        .foregroundStyle(UniTTColor.Text.secondary)
    }
}

private struct FormTextField: View {
    let label: String
    @Binding var text: String
    var prefix: String? = nil
    var count: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
            FormLabel(label, trailing: count)
            HStack {
                if let prefix {
                    Text(prefix).foregroundStyle(UniTTColor.Text.secondary)
                }
                TextField(label, text: $text)
                    .font(UniTTTypography.bodyMedium)
            }
            .padding(.horizontal, UniTTSpacing.Inset.cozy)
            .frame(height: 48)
            .background(UniTTColor.Background.elevated)
            .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
                    .stroke(UniTTColor.Border.default, lineWidth: 1)
            )
        }
    }
}

private struct StaticField: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
            FormLabel(label)
            Text(value)
                .font(UniTTTypography.bodyMedium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(UniTTSpacing.Inset.cozy)
                .primaryCard()
        }
    }
}

private struct PhotoSlot: View {
    let systemImage: String

    var body: some View {
        RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
            .fill(UniTTColor.Background.surface)
            .frame(width: 72, height: 72)
            .overlay(Image(systemName: systemImage).foregroundStyle(UniTTColor.Text.tertiary))
            .overlay(
                RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous)
                    .stroke(UniTTColor.Border.default, lineWidth: 1)
            )
    }
}

private struct CreateProgress: View {
    let stepNumber: Int
    let total: Int

    init(step: CreateStep) {
        stepNumber = min(step.rawValue + 1, 5)
        total = 5
    }

    init(stepNumber: Int, total: Int) {
        self.stepNumber = stepNumber
        self.total = total
    }

    var body: some View {
        HStack(spacing: UniTTSpacing.x6) {
            ForEach(1...total, id: \.self) { index in
                Capsule()
                    .fill(index <= stepNumber ? UniTTColor.Brand.primary : UniTTColor.Border.default)
                    .frame(height: 3)
            }
        }
    }
}

private struct InfoBoxSmall: View {
    let text: String

    var body: some View {
        Text(text)
            .font(UniTTTypography.bodySmall)
            .foregroundStyle(UniTTColor.Brand.primaryPressed)
            .lineSpacing(3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(UniTTSpacing.Inset.cozy)
            .background(UniTTColor.Brand.primarySubtle)
            .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.lg, style: .continuous))
    }
}

private struct ChatRow: View {
    let chat: MockChat

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.normal) {
            Circle()
                .fill(UniTTColor.Background.surface)
                .frame(width: 48, height: 48)
                .overlay(Text(String(chat.name.prefix(1))).font(UniTTTypography.labelMedium))
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                HStack {
                    Text(chat.name).font(UniTTTypography.bodyMedium.weight(.semibold))
                    Text(chat.time).font(UniTTTypography.labelSmall).foregroundStyle(UniTTColor.Text.secondary)
                }
                Text(chat.listingTitle).font(UniTTTypography.labelSmall).foregroundStyle(UniTTColor.Brand.primary)
                Text(chat.lastMessage).font(UniTTTypography.bodySmall).foregroundStyle(UniTTColor.Text.secondary)
            }
            Spacer()
            if chat.unreadCount > 0 {
                Text("\(chat.unreadCount)")
                    .font(UniTTTypography.labelSmall)
                    .foregroundStyle(UniTTColor.Text.onBrand)
                    .frame(width: 22, height: 22)
                    .background(UniTTColor.Brand.primary)
                    .clipShape(Circle())
            }
        }
        .padding(UniTTSpacing.Inset.cozy)
        .primaryCard()
    }
}

private struct ProductMiniBar: View {
    let title: String
    let status: ListingStatus

    var body: some View {
        HStack(spacing: UniTTSpacing.Inline.normal) {
            RoundedRectangle(cornerRadius: UniTTRadius.md, style: .continuous)
                .fill(UniTTColor.Background.surface)
                .frame(width: 44, height: 44)
                .overlay(Image(systemName: "photo").foregroundStyle(UniTTColor.Text.tertiary))
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                Text(title).font(UniTTTypography.bodyMedium.weight(.semibold)).lineLimit(1)
                StatusChip(status: status)
            }
            Spacer()
        }
        .padding(UniTTSpacing.Inset.cozy)
        .primaryCard()
    }
}

private struct MessageBubble: View {
    let text: String
    let mine: Bool

    var body: some View {
        HStack {
            if mine { Spacer(minLength: 40) }
            Text(text)
                .font(UniTTTypography.bodyMedium)
                .foregroundStyle(mine ? UniTTColor.Text.onBrand : UniTTColor.Text.primary)
                .padding(.horizontal, UniTTSpacing.Inset.cozy)
                .padding(.vertical, UniTTSpacing.Inset.compact)
                .background(mine ? UniTTColor.Brand.primary : UniTTColor.Background.surface)
                .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous))
            if !mine { Spacer(minLength: 40) }
        }
    }
}

private struct TimelineRow: View {
    let title: String
    let subtitle: String
    let active: Bool

    var body: some View {
        HStack(alignment: .top, spacing: UniTTSpacing.Inline.normal) {
            Circle()
                .fill(active ? UniTTColor.Brand.primary : UniTTColor.Border.default)
                .frame(width: 12, height: 12)
                .padding(.top, 4)
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                Text(title).font(UniTTTypography.bodyMedium.weight(.semibold))
                Text(subtitle).font(UniTTTypography.labelSmall).foregroundStyle(UniTTColor.Text.secondary)
            }
            Spacer()
        }
    }
}

private struct NotificationRow: View {
    let notification: MockNotification

    var body: some View {
        HStack(alignment: .top, spacing: UniTTSpacing.Inline.normal) {
            Text(notification.kind)
                .font(UniTTTypography.labelSmall)
                .foregroundStyle(UniTTColor.Brand.primary)
                .padding(.horizontal, UniTTSpacing.x8)
                .padding(.vertical, UniTTSpacing.x4)
                .background(UniTTColor.Brand.primarySubtle)
                .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.sm, style: .continuous))
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                Text(notification.title).font(UniTTTypography.bodyMedium.weight(.semibold))
                Text(notification.body).font(UniTTTypography.bodySmall).foregroundStyle(UniTTColor.Text.secondary)
                Text(notification.time).font(UniTTTypography.labelSmall).foregroundStyle(UniTTColor.Text.tertiary)
            }
            Spacer()
        }
        .padding(UniTTSpacing.Inset.cozy)
        .primaryCard()
    }
}

private struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                Text(title).font(UniTTTypography.bodyMedium.weight(.medium))
                Text(subtitle).font(UniTTTypography.labelSmall).foregroundStyle(UniTTColor.Text.secondary)
            }
        }
        .padding(UniTTSpacing.Inset.cozy)
        .primaryCard()
    }
}

private struct StatCell: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: UniTTSpacing.Stack.tight) {
            Text(value).font(UniTTTypography.heading3)
            Text(label).font(UniTTTypography.labelSmall).foregroundStyle(UniTTColor.Text.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, UniTTSpacing.Inset.cozy)
    }
}

private struct NavRow: View {
    let title: String
    let trailing: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title).font(UniTTTypography.bodyMedium)
                Spacer()
                Text(trailing).font(UniTTTypography.labelSmall).foregroundStyle(UniTTColor.Text.secondary)
                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(UniTTColor.Text.tertiary)
            }
            .padding(UniTTSpacing.Inset.cozy)
            .primaryCard()
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsSection: View {
    let title: String
    let danger: Bool

    init(_ title: String, danger: Bool = false) {
        self.title = title
        self.danger = danger
    }

    var body: some View {
        Text(title)
            .font(UniTTTypography.labelSmall.weight(.semibold))
            .foregroundStyle(danger ? UniTTColor.State.danger : UniTTColor.Text.secondary)
            .padding(.top, UniTTSpacing.Stack.relaxed)
    }
}

private struct StaticSettingsRow: View {
    let title: String
    var subtitle: String? = nil
    let trailing: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            SettingsRowContent(title: title, subtitle: subtitle, trailing: trailing, danger: false)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

private struct SettingsRowContent: View {
    let title: String
    let subtitle: String?
    let trailing: String
    let danger: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: UniTTSpacing.Stack.tight) {
                Text(title)
                    .font(UniTTTypography.bodyMedium.weight(.medium))
                    .foregroundStyle(danger ? UniTTColor.State.danger : UniTTColor.Text.primary)
                if let subtitle {
                    Text(subtitle).font(UniTTTypography.labelSmall).foregroundStyle(UniTTColor.Text.secondary)
                }
            }
            Spacer()
            Text(trailing)
                .font(UniTTTypography.labelSmall)
                .foregroundStyle(danger ? UniTTColor.State.danger : UniTTColor.Text.secondary)
        }
        .padding(UniTTSpacing.Inset.cozy)
        .primaryCard()
    }
}

private struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(UniTTTypography.labelLarge)
            .foregroundStyle(UniTTColor.Text.onBrand)
            .frame(maxWidth: .infinity)
            .frame(height: UniTTSize.ctaHeight)
            .background(configuration.isPressed ? UniTTColor.Brand.primaryPressed : UniTTColor.Brand.primary)
            .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous))
    }
}

private struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(UniTTTypography.labelLarge)
            .foregroundStyle(UniTTColor.Brand.primary)
            .frame(maxWidth: .infinity)
            .frame(height: UniTTSize.ctaHeight)
            .background(UniTTColor.Background.elevated)
            .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous)
                    .stroke(UniTTColor.Brand.primary, lineWidth: 1)
            )
    }
}

private struct DangerActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(UniTTTypography.labelLarge)
            .foregroundStyle(UniTTColor.Text.onBrand)
            .frame(maxWidth: .infinity)
            .frame(height: UniTTSize.ctaHeight)
            .background(UniTTColor.State.danger)
            .clipShape(RoundedRectangle(cornerRadius: UniTTRadius.xl, style: .continuous))
    }
}

private extension View {
    func chipStyle(selected: Bool) -> some View {
        self
            .font(UniTTTypography.labelMedium)
            .foregroundStyle(selected ? UniTTColor.Brand.primary : UniTTColor.Text.primary)
            .padding(.horizontal, UniTTSpacing.Inset.cozy)
            .padding(.vertical, UniTTSpacing.x8)
            .background(selected ? UniTTColor.Brand.primarySubtle : UniTTColor.Background.elevated)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(selected ? UniTTColor.Brand.primary : UniTTColor.Border.default, lineWidth: 1))
    }
}

#Preview {
    UserWireframeAppView()
}
