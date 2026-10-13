//
//  ProductDetailsScreen.swift
//  LoginTest
//
//  Created by Muhammad Mamun on 10/12/23.
//
import Foundation
import XCTest


extension ProductDetails {

    struct ProductDetailsScreen: Screen {
        var displayElement: XCUIElement { titleLabel }
        init() {
            waitForScreenDisplay(timeout: 10)
        }
    }
}

fileprivate extension ProductDetails.ProductDetailsScreen {
    var titleLabel: XCUIElement { app.navigationBars["Product"].firstMatch }
    var productTitle: XCUIElement { app.staticTexts["productDetailsIdentifier"].firstMatch }
    var price: XCUIElement { app.staticTexts["productPrice"].firstMatch }
    var description: XCUIElement { app.staticTexts["productDescription"].firstMatch }
    var addToCartButton: XCUIElement { app.buttons["addToCartButton"].firstMatch }
    var cartSummary: XCUIElement { app.staticTexts["cartSummary"].firstMatch }
}


extension ProductDetails.ProductDetailsScreen {

    var productTitleText: String {
        productTitle.waitUntilDisplayed(timeout: 8)
        return productTitle.label
    }

    var priceText: String {
        price.waitUntilDisplayed(timeout: 8)
        return price.label
    }

    var descriptionDisplayed: Bool { description.waitUntilDisplayed(timeout: 6) }

    var addToCartButtonDisplayed: Bool { addToCartButton.waitUntilDisplayed(timeout: 10) }

    /// "1 item in cart - User: emilys" after the first tap on Add to Cart.
    var cartSummaryText: String {
        cartSummary.waitUntilDisplayed(timeout: 5)
        return cartSummary.label
    }

    var cartSummaryShown: Bool { cartSummary.waitUntilDisplayed(timeout: 3) }

    @discardableResult
    func tapAddToCart() -> Self {
        addToCartButton.waitUntilDisplayed(timeout: 8)
        addToCartButton.tap()
        return self
    }

    @discardableResult
    func tapBack() -> ProductList.ProductListScreen {
        goBack(to: ProductList.ProductListScreen.self)
    }
}
