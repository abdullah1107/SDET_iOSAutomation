//
//  CartScreenTests.swift
//  LoginTest
//
//  Created by Muhammad Mamun on 10/10/26.
//

import XCTest

/// Run: python3 tools/main.py --test LoginTestUITests/CartScreenTests
final class CartUITests: BaseXCTestSetup {

    @MainActor
    func testEmptyCartShowsUserAndZeroItems() throws {
        Login.LoginScreen()
            .tapLoginButtonSuccess()
        Cart.CartScreen.openFromTabBar()
            .assertIsDisplayed()
            .assert({ $0.userText == "User: \(TestData.username)" }, "Wrong user on Cart tab")
            .assert({ $0.itemCountText == "Items in cart: 0" }, "Cart should be empty")
            .assert(\.emptyMessageShown, "Empty cart message not shown")
    }

    @MainActor
    func testAddedProductAppearsInCart() throws {
        Login.LoginScreen()
            .tapLoginButtonSuccess()
            .openFirstProduct()
            .tapAddToCart()

        Cart.CartScreen.openFromTabBar()
            .assert({ $0.userText == "User: \(TestData.username)" }, "Wrong user on Cart tab")
            .assert({ $0.itemCountText == "Items in cart: 1" }, "Cart should have 1 item")
            .assert(\.totalShown, "Cart total not shown")
    }

    @MainActor
    func testAddingSameProductTwiceCountsTwo() throws {
        Login.LoginScreen()
            .tapLoginButtonSuccess()
            .openFirstProduct()
            .tapAddToCart()
            .tapAddToCart()

        Cart.CartScreen.openFromTabBar()
            .assert({ $0.itemCountText == "Items in cart: 2" }, "Cart should have 2 items")
    }

    @MainActor
    func testTwoDifferentProductsAreBothInCart() throws {
        let list = Login.LoginScreen()
            .tapLoginButtonSuccess()
        list.openFirstProduct()
            .tapAddToCart()
            .tapBack()
        list.tapSearchField("Gucci")
        list.openProduct(matching: "Gucci")
            .tapAddToCart()

        Cart.CartScreen.openFromTabBar()
            .assert({ $0.itemCountText == "Items in cart: 2" }, "Cart should have 2 items")
    }
}
