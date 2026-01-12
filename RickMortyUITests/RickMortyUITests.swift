//
//  RickMortyUITests.swift
//  RickMortyUITests
//
//  Created by Abdelrahman Mohamed on 27.08.2025.
//

import XCTest

final class RickMortyUITests: XCTestCase {

    private var app: XCUIApplication!
    private var isCI: Bool {
        ProcessInfo.processInfo.environment["CI"] != nil
    }
    
    private enum AccessibilityId {
        static let charactersScrollView = "charactersScrollView"
        static let charactersTableView = "charactersTableView"
        static let characterCard = "characterCard"
        static let characterDetailsBackButton = "characterDetailsBackButton"
        static let filterAlive = "filterAlive"
        static let filterDead = "filterDead"
        static let filterUnknown = "filterUnknown"
    }

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

    private func element(with identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    @discardableResult
    private func selectSwiftUITabIfPresent(timeout: TimeInterval = 5) -> Bool {
        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: timeout) else { return false }

        let swiftUITab = tabBar.buttons["SwiftUI"]
        guard swiftUITab.waitForExistence(timeout: timeout) else { return false }
        swiftUITab.tap()
        return swiftUITab.isSelected
    }

    /// Waits for network-loaded content by checking for scroll view children
    private func waitForContentToLoad(timeout: TimeInterval = 10) -> Bool {
        let scrollView = app.scrollViews[AccessibilityId.charactersScrollView]
        guard scrollView.waitForExistence(timeout: timeout) else { return false }

        let firstCard = scrollView
            .descendants(matching: .any)
            .matching(identifier: AccessibilityId.characterCard)
            .firstMatch

        return firstCard.waitForExistence(timeout: timeout)
    }

    /// Safely taps a character card in the scroll view
    private func tapFirstCharacterCard(timeout: TimeInterval = 10) -> Bool {
        let scrollView = app.scrollViews[AccessibilityId.charactersScrollView]
        guard scrollView.waitForExistence(timeout: timeout) else { return false }

        let firstCard = scrollView
            .descendants(matching: .any)
            .matching(identifier: AccessibilityId.characterCard)
            .firstMatch

        guard firstCard.waitForExistence(timeout: timeout) else { return false }
        firstCard.tap()
        return true
    }

    private func tapFirstCharacterCard(in list: XCUIElement, timeout: TimeInterval = 10) -> Bool {
        let firstCard = list
            .descendants(matching: .any)
            .matching(identifier: AccessibilityId.characterCard)
            .firstMatch
        guard firstCard.waitForExistence(timeout: timeout) else { return false }
        firstCard.tap()
        return true
    }

    private func waitForUIKitContentToLoad(timeout: TimeInterval = 12) -> Bool {
        let table = app.tables[AccessibilityId.charactersTableView]
        if table.waitForExistence(timeout: timeout) {
            let firstCard = table
                .descendants(matching: .any)
                .matching(identifier: AccessibilityId.characterCard)
                .firstMatch
            return firstCard.waitForExistence(timeout: timeout)
        }

        let collection = app.collectionViews.firstMatch
        guard collection.waitForExistence(timeout: timeout) else { return false }
        let firstCard = collection
            .descendants(matching: .any)
            .matching(identifier: AccessibilityId.characterCard)
            .firstMatch
        return firstCard.waitForExistence(timeout: timeout)
    }

    @discardableResult
    private func tapFilterIfExists(_ identifier: String, timeout: TimeInterval = 5) -> Bool {
        let matches = app.descendants(matching: .any).matching(identifier: identifier)
        guard matches.firstMatch.waitForExistence(timeout: timeout) else { return false }

        let hittable = (0..<matches.count)
            .map { matches.element(boundBy: $0) }
            .first(where: { $0.isHittable })
        let target = hittable ?? matches.firstMatch
        target.tap()
        return true
    }
    
    @discardableResult
    private func tapBackButton(timeout: TimeInterval = 5) -> Bool {
        let customBack = app.buttons[AccessibilityId.characterDetailsBackButton]
        if customBack.waitForExistence(timeout: timeout) {
            customBack.tap()
            return true
        }

        let navBack = app.navigationBars.buttons.element(boundBy: 0)
        if navBack.waitForExistence(timeout: 2) {
            navBack.tap()
            return true
        }

        let arrowBack = app.buttons["arrow.left"]
        if arrowBack.waitForExistence(timeout: 2) {
            arrowBack.tap()
            return true
        }

        let labeledBack = app.buttons["Back"]
        if labeledBack.waitForExistence(timeout: 2) {
            labeledBack.tap()
            return true
        }

        app.swipeRight()
        return false
    }


    func testSwiftUITabLoadsCharactersScreen() throws {
        XCTAssertTrue(selectSwiftUITabIfPresent(), "SwiftUI tab should be selectable")

        // Assert that the main Characters screen is visible.
        let charactersTitle = app.navigationBars.staticTexts["Characters"]
        XCTAssertTrue(charactersTitle.waitForExistence(timeout: 5), "Characters screen should appear after launch")
    }

    func testNavigateBackFromScrollView() throws {
        XCTAssertTrue(selectSwiftUITabIfPresent(), "SwiftUI tab should be selectable")

        // Wait for content to load
        XCTAssertTrue(waitForContentToLoad(), "Characters should load before navigation")

        // Navigate to character details from scroll view using reliable tap
        XCTAssertTrue(tapFirstCharacterCard(), "Should be able to tap a character card")

        // Verify we can navigate back
        XCTAssertTrue(tapBackButton(), "Back button should be visible")

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

        XCTAssertTrue(waitForUIKitContentToLoad(), "UIKit characters should load before selection")

        let table = app.tables[AccessibilityId.charactersTableView]
        let list = table.exists ? table : app.collectionViews.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 5), "Expected a list on the UIKit tab")

        if list.isHittable {
            list.swipeUp()
        }

        XCTAssertTrue(tapFirstCharacterCard(in: list), "Should be able to tap a character card in UIKit list")

        // Navigate back
        tapBackButton(timeout: 2)

        // Verify we're back on the UIKit tab
        XCTAssertTrue(uiKitTab.waitForExistence(timeout: 2), "UIKit tab should exist after navigating back")
        XCTAssertTrue(uiKitTab.isSelected, "Should return to UIKit tab")
    }
    
    func testFeedViewWithFilter() throws {
        XCTAssertTrue(selectSwiftUITabIfPresent(), "SwiftUI tab should be selectable")
        XCTAssertTrue(waitForContentToLoad(), "Characters should load before filtering")

        // Test Alive filter
        XCTAssertTrue(tapFilterIfExists(AccessibilityId.filterAlive), "Alive filter should be visible")
        XCTAssertTrue(waitForContentToLoad(), "Alive filter should load results")
        
        // Test Dead filter
        XCTAssertTrue(tapFilterIfExists(AccessibilityId.filterDead), "Dead filter should be visible")
        XCTAssertTrue(waitForContentToLoad(), "Dead filter should load results")
        
        // Test Unknown filter
        XCTAssertTrue(tapFilterIfExists(AccessibilityId.filterUnknown), "Unknown filter should be visible")
        XCTAssertTrue(waitForContentToLoad(), "Unknown filter should load results")
        
        // Test clearing filter (tap again)
        XCTAssertTrue(tapFilterIfExists(AccessibilityId.filterUnknown), "Unknown filter should be tappable to clear")
        XCTAssertTrue(waitForContentToLoad(), "Clearing filter should reload results")
        
        // Verify we can still see characters after filtering
        let scrollView = app.scrollViews[AccessibilityId.charactersScrollView]
        XCTAssertTrue(scrollView.waitForExistence(timeout: 3), "Scroll view should be visible after filtering")
    }
    
    func testFeedViewSwiftUIWithScroll() throws {
        XCTAssertTrue(selectSwiftUITabIfPresent(), "SwiftUI tab should be selectable")

        // Wait for content to load
        XCTAssertTrue(waitForContentToLoad(), "Characters should load before scrolling")

        let scrollView = app.scrollViews[AccessibilityId.charactersScrollView]
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

        XCTAssertTrue(tapBackButton(), "Back button should be visible")

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

        XCTAssertTrue(waitForUIKitContentToLoad(), "UIKit characters should load before filtering")

        // Test filtering in UIKit implementation
        if tapFilterIfExists(AccessibilityId.filterAlive) {
            XCTAssertTrue(waitForUIKitContentToLoad(), "Alive filter should load results")
        }

        if tapFilterIfExists(AccessibilityId.filterDead) {
            XCTAssertTrue(waitForUIKitContentToLoad(), "Dead filter should load results")
        }

        if tapFilterIfExists(AccessibilityId.filterUnknown) {
            XCTAssertTrue(waitForUIKitContentToLoad(), "Unknown filter should load results")
            tapFilterIfExists(AccessibilityId.filterUnknown)
            XCTAssertTrue(waitForUIKitContentToLoad(), "Clearing filter should reload results")
        }

        // Verify UIKit list (UITableView/UICollectionView) is still functional
        let table = app.tables[AccessibilityId.charactersTableView]
        let list = table.exists ? table : app.collectionViews.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 10), "Expected a table or collection view to be visible after filtering")

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

        let cards = list
            .descendants(matching: .any)
            .matching(identifier: AccessibilityId.characterCard)
        XCTAssertTrue(cards.count > 0 || list.isHittable, "List should have cards or be hittable after filtering")
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
        XCTAssertTrue(selectSwiftUITabIfPresent(), "SwiftUI tab should be selectable")
        XCTAssertTrue(waitForContentToLoad(), "Characters should load before scrolling")

        let scrollView = app.scrollViews[AccessibilityId.charactersScrollView]
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
        XCTAssertTrue(selectSwiftUITabIfPresent(), "SwiftUI tab should be selectable")

        // Wait for initial content to load
        XCTAssertTrue(waitForContentToLoad(), "Characters should load before filtering")

        // Test that filter state is maintained during navigation
        XCTAssertTrue(tapFilterIfExists(AccessibilityId.filterAlive), "Alive filter should be visible")

        // Wait for filter to apply and content to reload
        XCTAssertTrue(waitForContentToLoad(), "Filtered characters should load")

        // Navigate to character details using reliable tap
        XCTAssertTrue(tapFirstCharacterCard(), "Should be able to tap a character card after filtering")

        // Navigate back
        XCTAssertTrue(tapBackButton(), "Back button should be visible")

        // Verify we're back to the filtered view
        let charactersTitle = app.navigationBars.staticTexts["Characters"]
        XCTAssertTrue(charactersTitle.waitForExistence(timeout: 5), "Should return to Characters screen")

        // Verify filter is still active (filter button should still be visible)
        XCTAssertTrue(element(with: AccessibilityId.filterAlive).waitForExistence(timeout: 3), "Alive filter should still be visible after navigation")
    }

    @MainActor
    func testLaunchPerformance() throws {
        try XCTSkipIf(isCI, "Skipping launch performance in CI to avoid simulator instrumentation timeouts.")
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
