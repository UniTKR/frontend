//
//  UniTTUITests.swift
//  UniTTUITests
//
//  Created by 천승환 on 5/15/26.
//

import XCTest

final class UniTTUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testUserAWireframeOnboardingFlow() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.otherElements["school-selection-screen"].waitForExistence(timeout: 5))

        app.buttons["school-row-snu"].tap()
        app.buttons["primary-cta"].tap()

        XCTAssertTrue(app.otherElements["email-verification-screen"].waitForExistence(timeout: 2))
        app.buttons["primary-cta"].tap()

        XCTAssertTrue(app.otherElements["otp-code-screen"].waitForExistence(timeout: 2))
        app.buttons["keypad-digit-1"].tap()
        app.buttons["keypad-digit-2"].tap()
        app.buttons["keypad-digit-3"].tap()

        XCTAssertTrue(app.otherElements["terms-agreement-screen"].waitForExistence(timeout: 2))
        app.buttons["primary-cta"].tap()

        XCTAssertTrue(app.otherElements["profile-setup-screen"].waitForExistence(timeout: 2))
        app.buttons["primary-cta"].tap()

        XCTAssertTrue(app.otherElements["user-home-screen"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testHomeSearchAndProductDetailFlow() throws {
        let app = XCUIApplication()
        launchPastOnboarding(app)

        XCTAssertTrue(app.otherElements["user-home-screen"].waitForExistence(timeout: 3))
        app.buttons["category-textbook-button"].tap()
        app.buttons["product-card-data-structure"].tap()

        XCTAssertTrue(app.otherElements["product-detail-screen"].waitForExistence(timeout: 2))
        app.buttons["top-back-button"].tap()

        app.buttons["tab-검색"].tap()
        XCTAssertTrue(app.otherElements["search-screen"].waitForExistence(timeout: 2))
        app.buttons["recent-search-airpods"].tap()
        app.buttons["search-result-airpods"].tap()

        XCTAssertTrue(app.otherElements["product-detail-screen"].waitForExistence(timeout: 2))
        app.buttons["top-right-button"].tap()
        XCTAssertTrue(app.otherElements["report-flow-screen"].waitForExistence(timeout: 2))
        app.buttons["report-next"].tap()
        app.buttons["report-reason-noshow"].tap()
        app.buttons["report-next"].tap()
        app.buttons["report-next"].tap()
        XCTAssertTrue(app.otherElements["report-done-screen"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCreateChatSafetyAndSettingsFlows() throws {
        let app = XCUIApplication()
        launchPastOnboarding(app)

        app.buttons["tab-등록"].tap()
        XCTAssertTrue(app.otherElements["listing-create-screen"].waitForExistence(timeout: 2))
        app.buttons["create-category-textbook"].tap()
        app.buttons["create-next"].tap()
        app.buttons["create-next"].tap()
        app.buttons["create-next"].tap()
        app.buttons["create-next"].tap()
        app.buttons["create-submit"].tap()
        XCTAssertTrue(app.otherElements["create-done-screen"].waitForExistence(timeout: 2))
        app.buttons["create-done-home"].tap()

        app.buttons["tab-채팅"].tap()
        app.buttons["chat-row-chat-airpods"].tap()
        XCTAssertTrue(app.otherElements["chat-room-screen"].waitForExistence(timeout: 2))
        app.buttons["block-user-button"].tap()
        XCTAssertTrue(app.otherElements["block-list-screen"].waitForExistence(timeout: 2))
        app.buttons["top-back-button"].tap()
        app.buttons["tab-채팅"].tap()
        app.buttons["chat-row-chat-airpods"].tap()
        app.buttons["appointment-menu-button"].tap()
        app.buttons["appointment-submit-button"].tap()
        XCTAssertTrue(app.otherElements["trade-panel-screen"].waitForExistence(timeout: 2))
        app.buttons["trade-complete-button"].tap()

        app.buttons["top-back-button"].tap()
        app.buttons["tab-마이"].tap()
        app.buttons["my-settings-button"].tap()
        XCTAssertTrue(app.otherElements["settings-screen"].waitForExistence(timeout: 2))
        app.swipeUp()
        app.swipeUp()
        app.buttons["settings-logout-button"].tap()
    }

    @MainActor
    private func launchPastOnboarding(_ app: XCUIApplication) {
        app.launch()
        if app.otherElements["user-home-screen"].waitForExistence(timeout: 1) {
            return
        }

        app.buttons["school-row-snu"].tap()
        app.buttons["primary-cta"].tap()
        app.buttons["primary-cta"].tap()
        app.buttons["keypad-digit-1"].tap()
        app.buttons["keypad-digit-2"].tap()
        app.buttons["keypad-digit-3"].tap()
        app.buttons["primary-cta"].tap()
        app.buttons["primary-cta"].tap()
        XCTAssertTrue(app.otherElements["user-home-screen"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
