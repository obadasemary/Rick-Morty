//
//  RickMortyUITests.swift
//  RickMortyUITests
//
//  Created by Abdelrahman Mohamed on 27.08.2025.
//

import XCTest

final class RickMortyUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        // Pass a flag so the app can configure mock data or faster startup if it supports it.
        app.launchArguments += ["-ui-testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }


    func testSwiftUITabLoadsCharactersScreen() throws {
        // Assert that the main Characters screen is visible.
        let charactersTitle = app.navigationBars.staticTexts["Characters"]
        XCTAssertTrue(charactersTitle.waitForExistence(timeout: 5), "Characters screen should appear after launch")
    }

    
    func testNavigateBackFromScrollView() throws {
        app = XCUIApplication()
        app.launch()
        
        app.activate()
        app.scrollViews.firstMatch.tap()
        app.buttons["arrow.left"].tap()
    }

    func testSwitchToUIKitTabIfPresent() throws {
        // If your app exposes a UIKit tab (labelled "UIKit"), verify that it can be selected.
        let uiKitTab = app.tabBars.buttons["UIKit"].firstMatch
        if uiKitTab.waitForExistence(timeout: 2) {
            uiKitTab.tap()
            XCTAssertTrue(uiKitTab.isSelected, "UIKit tab should be selected")
        } else {
            throw XCTSkip("UIKit tab not present; skipping tab switch test.")
        }
    }
    
    func testSwitchToUIKitTabAndOpenCharacterDetailsAndThenBack() throws {
        app = XCUIApplication()
        app.activate()
        app.buttons["UIKit"].tap()
        app.otherElements.containing(.staticText, identifier: "Beth Smith").firstMatch.swipeUp()
        app.staticTexts["Jerry Smith"].tap()
        app.buttons["arrow.left"].tap()
    }
    
    func testFeedViewWithFilter() throws {
        app = XCUIApplication()
        app.activate()
        app.staticTexts["Alive"].tap()
        app.staticTexts["Dead"].tap()

        let unknownStaticText = app.staticTexts["Unknown"]
        unknownStaticText.tap()
        unknownStaticText.tap()
    }
    
    func testFeedViewSwiftUIWithScroll() throws {
        app = XCUIApplication()
        let app = XCUIApplication()
        app.activate()
        let scrollViewsQuery = app.scrollViews
        let element = scrollViewsQuery.firstMatch
        element.swipeRight()
        element.swipeRight()

        let element2 = scrollViewsQuery.firstMatch
        element2.swipeRight()
        element2.swipeUp()

        let element3 = scrollViewsQuery.firstMatch
        element3.tap()

        let arrowLeftButton = app.buttons["arrow.left"]
        arrowLeftButton.tap()
        element3.tap()
        arrowLeftButton.tap()
        element3.swipeRight()
        element3.swipeUp()
        scrollViewsQuery.firstMatch.tap()
        arrowLeftButton.tap()
        app.activate()
    }
    
    func testFeedListViewUIKitWithFilter() throws {
        app = XCUIApplication()
        app.activate()
        app.buttons["UIKit"].tap()
        app.staticTexts["Alive"].tap()
        app.staticTexts["Dead"].tap()

        let unknownStaticText = app.staticTexts["Unknown"]
        unknownStaticText.tap()
        unknownStaticText.tap()
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
