//
//  Screen.swift
//  AuthenticationSwiftUIUITests
//
//  Created by Muhammad Mamun on 9/12/23.
//

import Foundation
import XCTest

protocol Screen {
    init()
    var displayElement: XCUIElement { get }
}

extension Screen {
    var app: XCUIApplication {
        XCUIApplication()
    }

    var isDisplayed: Bool {
        displayElement.exists
    }

    fileprivate var navBarBackButton: XCUIElement {
        app.navigationBars.buttons.element(boundBy: 0)
    }

    @discardableResult
    func waitForScreenDisplay(timeout: TimeInterval = 3) -> Bool {
        displayElement.waitUntilDisplayed(timeout: timeout)
    }

    @discardableResult
    func goBack<T: Screen>(to screen: T.Type) -> T {
        navBarBackButton.waitUntilDisplayed()
        navBarBackButton.tap()
        return screen.init()
    }

    @discardableResult
    func dismissModalScreen<T: Screen>(to screen: T.Type) -> T {
        navBarBackButton.waitUntilDisplayed()
        navBarBackButton.swipeUp()
        return screen.init()
    }

    func scrollToElement(_ element: XCUIElement) {
        while !element.isVisible {
            app.swipeUp()
        }
    }

    var alertController: XCUIElement {
        app.alerts.firstMatch
    }
}

extension Screen {
    @discardableResult
    func assertIsDisplayed() -> Self {
        XCTAssertTrue(isDisplayed, "ERROR: \(displayElement) not displayed.")
        return self
    }

    @discardableResult
    func assertDisplayed<T: Screen>(_ screen: T) -> T {
        XCTAssert(screen.isDisplayed, "ERROR: \(screen.displayElement) not displayed.")
        return screen
    }

    @discardableResult
    func assert(_ expression: @escaping (Self) -> Bool, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssert(expression(self), message, file: file, line: line)
        return self
    }

    @discardableResult
    func assert(_ keyPath: KeyPath<Self, Bool>, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) -> Self {
        assert(keyPath, equals: true, message, file: file, line: line)
    }

    @discardableResult
    func assert<Value: Equatable>(_ keyPath: KeyPath<Self, Value>, equals expectation: Value, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) -> Self {
        XCTAssert(self[keyPath: keyPath] == expectation, message, file: file, line: line)
        return self
    }
}

extension Screen {

    // temporary solution for go back to previous screen, because error toast prevents back button tap.
    @discardableResult
    func goBackToPreviousScreen<T: Screen>(to screen: T.Type) -> T {

        navBarBackButton.waitUntilDisplayed()
        while navBarBackButton.isVisible {
            navBarBackButton.tap()
        }

        return screen.init()
    }
}

extension Screen {
    func waitInScreen(timeout: TimeInterval = 3) {
        _ = XCTWaiter.wait(for: [XCTestExpectation(description: "Wait for n seconds")], timeout: timeout)
    }
}

extension XCUIElement {
    var isVisible: Bool {
        guard exists, !frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }

    @discardableResult
    func waitUntilDisplayed(timeout: TimeInterval = 3) -> Bool {
        waitForExistence(timeout: timeout)
    }

    func textFieldDataInsert(_ textFieldData: String) {
        tap()
        typeText(textFieldData)
    }
}

extension XCUIElement {
    func waitUntilElementAppear(timeout: TimeInterval = 3) {
        _ = XCTWaiter.wait(for: [XCTestExpectation(description: "Wait for n seconds")], timeout: timeout)
    }
}

extension XCUIElementQuery {

    // find regEx match for element
    /// Example: app.buttons.softMatching(substring: "Help")
    func softMatching(substring: String) -> [XCUIElement] {
        allElementsBoundByIndex.filter { $0.label.contains(substring) }
    }
}
