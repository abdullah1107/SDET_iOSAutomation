//
//  CartScreen.swift
//  LoginTest
//
//  Created by Muhammad Mamun on 10/10/26.
//

import Foundation
import XCTest

extension Cart {

    struct CartScreen: Screen {
        var displayElement: XCUIElement { titleLabel }
        init() {
            waitForScreenDisplay(timeout: 10)
        }

        /// Taps the "Cart" tab in the bottom tab bar.
        static func openFromTabBar() -> CartScreen {
            let tab = XCUIApplication().tabBars.buttons["Cart"].firstMatch
            _ = tab.waitForExistence(timeout: 10)
            tab.tap()
            return CartScreen()
        }
    }
}

fileprivate extension Cart.CartScreen {
    var titleLabel: XCUIElement { app.navigationBars["Cart"].firstMatch }
    var userLabel: XCUIElement { app.staticTexts["cartUserLabel"].firstMatch }
    var itemCountLabel: XCUIElement { app.staticTexts["cartItemCountLabel"].firstMatch }
    var emptyLabel: XCUIElement { app.staticTexts["cartEmptyLabel"].firstMatch }
    var totalLabel: XCUIElement { app.staticTexts["cartTotalLabel"].firstMatch }
}

extension Cart.CartScreen {

    var userText: String {
        userLabel.waitUntilDisplayed(timeout: 5)
        return userLabel.label
    }

    var itemCountText: String {
        itemCountLabel.waitUntilDisplayed(timeout: 5)
        return itemCountLabel.label
    }

    var emptyMessageShown: Bool { emptyLabel.waitUntilDisplayed(timeout: 3) }

    var totalShown: Bool { totalLabel.waitUntilDisplayed(timeout: 5) }

    /// Number of product rows in the cart (rows are identified as cartLine_<id>).
    var lineCount: Int {
        app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'cartLine_'")).count
    }
}
