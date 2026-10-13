//
//  ProductDetailsTests.swift
//  LoginTest
//
//  Created by Muhammad Mamun on 10/12/23.
//

import XCTest

/// Run: python3 tools/main.py --test LoginTestUITests/ProductDetailsTests
final class ProductDetailsTests: BaseXCTestSetup {

    @MainActor
    func testProductDetailsShowTitleAndPrice() throws {
        Login.LoginScreen()
            .tapLoginButtonSuccess()
            .tapSearchField("Gucci")
            .openProduct(matching: "Gucci")
            .assert({ $0.productTitleText.localizedCaseInsensitiveContains("Gucci") }, "Title does not contain Gucci")
            .assert({ $0.priceText.hasPrefix("$") }, "Price is not shown")
            .assert(\.descriptionDisplayed, "Description not shown")
    }

    @MainActor
    func testAddToCartButtonIsShown() throws {
        Login.LoginScreen()
            .tapLoginButtonSuccess()
            .openFirstProduct()
            .assert(\.addToCartButtonDisplayed, "Add to Cart button not shown")
            .assert(\.cartSummaryShown, equals: false, "Cart summary must be empty before Add to Cart")
    }

    @MainActor
    func testAddToCartShowsItemCountAndUser() throws {
        let details = Login.LoginScreen()
            .tapLoginButtonSuccess()
            .openFirstProduct()
            .tapAddToCart()
        XCTAssertTrue(details.cartSummaryText.contains("1 item"), "Wrong count: \(details.cartSummaryText)")
        XCTAssertTrue(details.cartSummaryText.contains(TestData.username), "Wrong user: \(details.cartSummaryText)")
    }


}















// MARK: - add Test scenario here

//    @MainActor
//    func testProductDetailsScreenDisplay() throws {
//        Login.LoginScreen()
//            .tapLoginButtonSuccess()
//            .openFirstProduct()
//            .assertDisplayed(ProductDetails.ProductDetailsScreen())
//    }


//    @MainActor
//    func testBackToProductList() throws {
//        Login.LoginScreen()
//            .tapLoginButtonSuccess()
//            .openFirstProduct()
//            .tapBack()
//            .assertDisplayed(ProductList.ProductListScreen())
//    }
