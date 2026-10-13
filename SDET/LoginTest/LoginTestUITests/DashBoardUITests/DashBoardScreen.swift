//
//  DashBoardScreen.swift
//  AuthenticationSwiftUIUITests
//
//  Created by Muhammad Mamun on 10/12/23.
//

import Foundation
import XCTest


extension ProductList {
    
    struct ProductListScreen: Screen {
        var displayElement: XCUIElement { titleLabel }
        init() {
            waitForScreenDisplay(timeout: 10)
        }
    }
}

fileprivate extension ProductList.ProductListScreen {
   
    static let navTitle = "Dashboard"
    var titleLabel: XCUIElement { app.navigationBars[Self.navTitle].firstMatch }
    var loginSuccessToast: XCUIElement { app.staticTexts["loginSuccessAlert"].firstMatch }
    var searchBarTextField: XCUIElement { app.searchFields["Search Product"] }
    var searchingCells: XCUIElement { app.cells.firstMatch } // .element crashes when several rows match
}


extension ProductList.ProductListScreen {
    
    /// Non-waiting-heavy check used to prove the dashboard is NOT on screen.
    static var isShownQuickly: Bool {
        XCUIApplication().navigationBars[navTitle].firstMatch.waitForExistence(timeout: 1)
    }
    
    var firstProductCellDisplayed: Bool {
        app.cells.firstMatch.waitUntilDisplayed(timeout: 10)
    }
    
    var loginSuccessAlertToast: String {
        loginSuccessToast.waitUntilDisplayed()
        return loginSuccessToast.label
    }
    
    @discardableResult
    func tapSearchField(_ searchItem:String) -> Self {
        searchBarTextField.waitUntilDisplayed()
        searchBarTextField.tap()
        searchBarTextField.typeText(searchItem)
        return self
    }
    
    var searchItemFound: Int {
        searchingCells.waitUntilDisplayed(timeout: 10)
        return app.cells.count
    }
    
    
    /// Taps the product and returns the Product Details screen.
    func openProduct(matching name: String) -> ProductDetails.ProductDetailsScreen {
        tapProduct(matching: name)
        return ProductDetails.ProductDetailsScreen()
    }

    /// Taps the first row of the list and returns the Product Details screen.
    func openFirstProduct() -> ProductDetails.ProductDetailsScreen {
        _ = app.cells.firstMatch.waitForExistence(timeout: 15)
        app.cells.firstMatch.tap()
        return ProductDetails.ProductDetailsScreen()
    }

    /// The list loads 10 products at a time and builds rows lazily, so the product may not be on screen yet.
    /// Scroll down until its title is visible and hittable, then tap the title (taps the whole row).
    @discardableResult
    func tapProduct(matching name: String) -> Self {
        let match = NSPredicate(format: "label CONTAINS[cd] %@", name)
        func visibleRow() -> XCUIElement? {
            [app.cells.matching(match).firstMatch,
             app.buttons.matching(match).firstMatch,
             app.staticTexts.matching(match).firstMatch].first { $0.exists && $0.isHittable }
        }
        waitInScreen(timeout: 10)
        var swipes = 0
        while visibleRow() == nil && swipes < 15 {
            if app.keyboards.count > 0 { app.swipeDown() } else { app.swipeUp() }
            swipes += 1
        }
        guard let row = visibleRow() else {
            XCTFail("Product '\(name)' not found in the list after scrolling")
            return self
        }
        row.tap()
        return self
    }
    
    

}



















//    @discardableResult
//    func tapSearchElementItem() -> ProductDetails.ProductElement{
//        searchingCells.waitUntilDisplayed(timeout: 10)
//        app.cells.element(boundBy: 0).tap()
//        return ProductDetails.ProductElement()
//    }
