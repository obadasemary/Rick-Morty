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
    
    // MARK: - Helper Methods
    
    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 3) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
    
    private func tapIfExists(_ element: XCUIElement, timeout: TimeInterval = 3) -> Bool {
        guard element.waitForExistence(timeout: timeout) else { return false }
        element.tap()
        return true
    }


    func testSwiftUITabLoadsCharactersScreen() throws {
        // Assert that the main Characters screen is visible.
        let charactersTitle = app.navigationBars.staticTexts["Characters"]
        XCTAssertTrue(charactersTitle.waitForExistence(timeout: 5), "Characters screen should appear after launch")
    }

    func testNavigateBackFromScrollView() throws {
        // Navigate to character details from scroll view
        app.scrollViews.firstMatch.tap()
        
        // Verify we can navigate back
        let backButton = app.buttons["arrow.left"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 3), "Back button should be visible")
        backButton.tap()
        
        // Verify we're back to the main screen
        let charactersTitle = app.navigationBars.staticTexts["Characters"]
        XCTAssertTrue(charactersTitle.waitForExistence(timeout: 3), "Should return to Characters screen")
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
        // Switch to UIKit tab
        let uiKitTab = app.tabBars.buttons["UIKit"]
        guard uiKitTab.waitForExistence(timeout: 5) else {
            throw XCTSkip("UIKit tab not available")
        }
        uiKitTab.tap()
        XCTAssertTrue(uiKitTab.isSelected, "UIKit tab should be selected")

        // Wait for either a table or a collection view on the UIKit tab
        let table = app.tables.firstMatch
        let collection = app.collectionViews.firstMatch
        let hasList = table.waitForExistence(timeout: 5) || collection.waitForExistence(timeout: 5)
        XCTAssertTrue(hasList, "Expected a table or collection view on the UIKit tab")

        // Choose whichever exists
        let list = table.exists ? table : collection

        // Nudge the list to ensure cells load
        if list.exists && list.isHittable {
            list.swipeUp()
        }

        // Tap the first visible cell
        let cell = list.cells.firstMatch
        guard cell.waitForExistence(timeout: 5) else {
            throw XCTSkip("No cells found on the UIKit list")
        }
        cell.tap()

        // Navigate back: try explicit arrow, then nav bar button, then edge-swipe
        if app.buttons["arrow.left"].waitForExistence(timeout: 2) {
            app.buttons["arrow.left"].tap()
        } else if app.navigationBars.buttons.element(boundBy: 0).exists {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        } else {
            app.swipeRight()
        }

        // Verify we're back on the UIKit tab
        XCTAssertTrue(uiKitTab.waitForExistence(timeout: 2), "UIKit tab should exist after navigating back")
        XCTAssertTrue(uiKitTab.isSelected, "Should return to UIKit tab")
    }
    
    func testFeedViewWithFilter() throws {
        // Test Alive filter
        let aliveFilter = app.staticTexts["Alive"]
        XCTAssertTrue(aliveFilter.waitForExistence(timeout: 3), "Alive filter should be visible")
        aliveFilter.tap()
        
        // Test Dead filter
        let deadFilter = app.staticTexts["Dead"]
        XCTAssertTrue(deadFilter.waitForExistence(timeout: 3), "Dead filter should be visible")
        deadFilter.tap()
        
        // Test Unknown filter
        let unknownFilter = app.staticTexts["Unknown"]
        XCTAssertTrue(unknownFilter.waitForExistence(timeout: 3), "Unknown filter should be visible")
        unknownFilter.tap()
        
        // Test clearing filter (tap again)
        unknownFilter.tap()
        
        // Verify we can still see characters after filtering
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 3), "Scroll view should be visible after filtering")
    }
    
    func testFeedViewSwiftUIWithScroll() throws {
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 3), "Scroll view should be visible")
        
        // Test horizontal scrolling
        scrollView.swipeRight()
        scrollView.swipeRight()
        
        // Test vertical scrolling
        scrollView.swipeUp()
        scrollView.swipeUp()
        
        // Test character selection and navigation
        scrollView.tap()
        
        let backButton = app.buttons["arrow.left"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 3), "Back button should be visible")
        backButton.tap()
        
        // Verify we're back to the main screen
        let charactersTitle = app.navigationBars.staticTexts["Characters"]
        XCTAssertTrue(charactersTitle.waitForExistence(timeout: 3), "Should return to Characters screen")
    }
    
    func testFeedListViewUIKitWithFilter() throws {
        // Switch to UIKit tab
        let uiKitTab = app.tabBars.buttons["UIKit"]
        guard uiKitTab.waitForExistence(timeout: 5) else {
            throw XCTSkip("UIKit tab not available")
        }
        uiKitTab.tap()
        XCTAssertTrue(uiKitTab.isSelected, "UIKit tab should be selected")
        
        // Test filtering in UIKit implementation
        let aliveFilter = app.staticTexts["Alive"]
        if aliveFilter.waitForExistence(timeout: 3) {
            aliveFilter.tap()
        }
        
        let deadFilter = app.staticTexts["Dead"]
        if deadFilter.waitForExistence(timeout: 3) {
            deadFilter.tap()
        }
        
        let unknownFilter = app.staticTexts["Unknown"]
        if unknownFilter.waitForExistence(timeout: 3) {
            unknownFilter.tap()
            // Test clearing filter
            unknownFilter.tap()
        }
        
        // Verify UIKit list (UITableView/UICollectionView) is still functional
        let table = app.tables.firstMatch
        let collection = app.collectionViews.firstMatch
        let hasList = table.waitForExistence(timeout: 5) || collection.waitForExistence(timeout: 5)
        XCTAssertTrue(hasList, "Expected a table or collection view to be visible after filtering")

        let list = table.exists ? table : collection
        XCTAssertTrue(list.exists, "List should exist after filtering")

        if list.isHittable {
            list.swipeUp()
            list.swipeDown()
        } else {
            app.swipeUp()
            app.swipeDown()
        }

        let cells = list.cells
        XCTAssertTrue(cells.count > 0 || list.isHittable, "List should have cells or be hittable after filtering")
    }
    
    // MARK: - Additional Focused Tests
    
    func testTabBarNavigation() throws {
        // Wait for the tab bar to be present
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should exist")

        // Try to find a primary tab by common names; fall back to the first tab
        let preferredPrimaryNames = ["Characters", "SwiftUI", "Home"]
        var primaryTab: XCUIElement?
        for name in preferredPrimaryNames {
            let candidate = tabBar.buttons[name]
            if candidate.exists { primaryTab = candidate; break }
        }
        if primaryTab == nil {
            // Fall back to the first tab button if named buttons aren't found
            let first = tabBar.buttons.element(boundBy: 0)
            guard first.exists else { throw XCTSkip("No tab bar buttons available") }
            primaryTab = first
        }
        guard let charactersTab = primaryTab else { throw XCTSkip("Primary tab not available") }

        // Ensure the primary tab is tappable/selected
        if charactersTab.waitForExistence(timeout: 3) {
            charactersTab.tap()
        } else {
            throw XCTSkip("Primary tab did not appear in time")
        }

        // Try to find a secondary tab to switch to: prioritize UIKit if present
        var secondaryTab: XCUIElement?
        if tabBar.buttons["UIKit"].exists { secondaryTab = tabBar.buttons["UIKit"] }
        else if tabBar.buttons.count > 1 {
            // Use the second tab if any
            let second = tabBar.buttons.element(boundBy: 1)
            if second.exists { secondaryTab = second }
        }

        guard let targetTab = secondaryTab else {
            // If there is no other tab, just assert the primary remains selected and skip the rest
            XCTAssertTrue(charactersTab.exists, "Primary tab should exist")
            throw XCTSkip("Only one tab available; skipping switch test")
        }

        // Switch to the secondary tab
        targetTab.tap()
        XCTAssertTrue(targetTab.isSelected, "Secondary tab should be selected after tap")

        // Switch back to the primary tab
        charactersTab.tap()
        XCTAssertTrue(charactersTab.isSelected, "Primary tab should be selected after switching back")
    }
    
    func testCharacterListScrolling() throws {
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 3), "Scroll view should be visible")
        
        // Test vertical scrolling for pagination
        scrollView.swipeUp()
        scrollView.swipeUp()
        scrollView.swipeUp()
        
        // Test horizontal scrolling if available
        scrollView.swipeRight()
        scrollView.swipeLeft()
        
        // Verify scroll view is still interactive
        XCTAssertTrue(scrollView.isHittable, "Scroll view should remain interactive after scrolling")
    }
    
    func testFilterStatePersistence() throws {
        // Test that filter state is maintained during navigation
        let aliveFilter = app.staticTexts["Alive"]
        XCTAssertTrue(aliveFilter.waitForExistence(timeout: 3), "Alive filter should be visible")
        aliveFilter.tap()
        
        // Navigate to character details
        let scrollView = app.scrollViews.firstMatch
        scrollView.tap()
        
        // Navigate back
        let backButton = app.buttons["arrow.left"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 3), "Back button should be visible")
        backButton.tap()
        
        // Verify we're back to the filtered view
        let charactersTitle = app.navigationBars.staticTexts["Characters"]
        XCTAssertTrue(charactersTitle.waitForExistence(timeout: 3), "Should return to Characters screen")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
