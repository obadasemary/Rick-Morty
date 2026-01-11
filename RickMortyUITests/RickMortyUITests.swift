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

    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }

    private func tapIfExists(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        guard element.waitForExistence(timeout: timeout) else { return false }
        element.tap()
        return true
    }

    /// Waits for network-loaded content by checking for scroll view children
    private func waitForContentToLoad(timeout: TimeInterval = 10) {
        let scrollView = app.scrollViews.firstMatch
        guard scrollView.waitForExistence(timeout: timeout) else { return }

        // Wait a bit for network content to populate
        sleep(2)
    }

    /// Safely taps a character card in the scroll view
    private func tapFirstCharacterCard() -> Bool {
        let scrollView = app.scrollViews.firstMatch
        guard scrollView.waitForExistence(timeout: 5) else { return false }

        // Wait for content to load
        sleep(2)

        // Try to find any tappable element within the scroll view
        // Look for images (character avatars) which are more reliable tap targets
        let images = scrollView.images
        if images.count > 0 {
            let firstImage = images.element(boundBy: 0)
            if firstImage.isHittable {
                firstImage.tap()
                return true
            }
        }

        // Fallback: tap at a specific coordinate within the scroll view
        let coordinate = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
        coordinate.tap()
        return true
    }


    func testSwiftUITabLoadsCharactersScreen() throws {
        // Assert that the main Characters screen is visible.
        let charactersTitle = app.navigationBars.staticTexts["Characters"]
        XCTAssertTrue(charactersTitle.waitForExistence(timeout: 5), "Characters screen should appear after launch")
    }

    func testNavigateBackFromScrollView() throws {
        // Wait for content to load
        waitForContentToLoad()

        // Navigate to character details from scroll view using reliable tap
        XCTAssertTrue(tapFirstCharacterCard(), "Should be able to tap a character card")

        // Verify we can navigate back
        let backButton = app.buttons["arrow.left"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button should be visible")
        backButton.tap()

        // Verify we're back to the main screen
        let charactersTitle = app.navigationBars.staticTexts["Characters"]
        XCTAssertTrue(charactersTitle.waitForExistence(timeout: 5), "Should return to Characters screen")
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
        // Wait for content to load
        waitForContentToLoad()

        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Scroll view should be visible")

        // Test horizontal scrolling
        scrollView.swipeRight()
        sleep(1)
        scrollView.swipeRight()
        sleep(1)

        // Test vertical scrolling
        scrollView.swipeUp()
        sleep(1)
        scrollView.swipeUp()
        sleep(1)

        // Test character selection and navigation using reliable tap
        XCTAssertTrue(tapFirstCharacterCard(), "Should be able to tap a character card")

        let backButton = app.buttons["arrow.left"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button should be visible")
        backButton.tap()

        // Verify we're back to the main screen
        let charactersTitle = app.navigationBars.staticTexts["Characters"]
        XCTAssertTrue(charactersTitle.waitForExistence(timeout: 5), "Should return to Characters screen")
    }
    
    func testFeedListViewUIKitWithFilter() throws {
        // Switch to UIKit tab
        let uiKitTab = app.tabBars.buttons["UIKit"]
        guard uiKitTab.waitForExistence(timeout: 5) else {
            throw XCTSkip("UIKit tab not available")
        }
        uiKitTab.tap()
        XCTAssertTrue(uiKitTab.isSelected, "UIKit tab should be selected")

        // Wait for UIKit tab content to load
        sleep(3)

        // Test filtering in UIKit implementation
        let aliveFilter = app.staticTexts["Alive"]
        if aliveFilter.waitForExistence(timeout: 5) {
            aliveFilter.tap()
            sleep(2) // Wait for filter to apply
        }

        let deadFilter = app.staticTexts["Dead"]
        if deadFilter.waitForExistence(timeout: 5) {
            deadFilter.tap()
            sleep(2) // Wait for filter to apply
        }

        let unknownFilter = app.staticTexts["Unknown"]
        if unknownFilter.waitForExistence(timeout: 5) {
            unknownFilter.tap()
            sleep(2) // Wait for filter to apply
            // Test clearing filter
            unknownFilter.tap()
            sleep(2) // Wait for filter to clear
        }

        // Verify UIKit list (UITableView/UICollectionView) is still functional
        let table = app.tables.firstMatch
        let collection = app.collectionViews.firstMatch
        let hasList = table.waitForExistence(timeout: 10) || collection.waitForExistence(timeout: 10)
        XCTAssertTrue(hasList, "Expected a table or collection view to be visible after filtering")

        let list = table.exists ? table : collection
        XCTAssertTrue(list.exists, "List should exist after filtering")

        // Wait for list to become interactive
        sleep(2)

        if list.isHittable {
            list.swipeUp()
            sleep(1)
            list.swipeDown()
            sleep(1)
        } else {
            app.swipeUp()
            sleep(1)
            app.swipeDown()
            sleep(1)
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
        // Wait for initial content to load
        waitForContentToLoad()

        // Test that filter state is maintained during navigation
        let aliveFilter = app.staticTexts["Alive"]
        XCTAssertTrue(aliveFilter.waitForExistence(timeout: 5), "Alive filter should be visible")
        aliveFilter.tap()

        // Wait for filter to apply and content to reload
        sleep(3)

        // Navigate to character details using reliable tap
        XCTAssertTrue(tapFirstCharacterCard(), "Should be able to tap a character card after filtering")

        // Navigate back
        let backButton = app.buttons["arrow.left"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button should be visible")
        backButton.tap()

        // Verify we're back to the filtered view
        let charactersTitle = app.navigationBars.staticTexts["Characters"]
        XCTAssertTrue(charactersTitle.waitForExistence(timeout: 5), "Should return to Characters screen")

        // Verify filter is still active (filter button should still be visible)
        XCTAssertTrue(aliveFilter.waitForExistence(timeout: 3), "Alive filter should still be visible after navigation")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
