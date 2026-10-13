//
//  ProductDashBoardTests.swift
//  AuthenticationSwiftUIUITests
//
//  Created by Muhammad Mamun on 10/12/23.
//
//override var additionalLaunchArguments: [String] { ["--logged-in"] }

import XCTest


final class ProductListTests: BaseXCTestSetup {

    @MainActor
    func testProductDashBoardDisPlay()throws{
        Login.LoginScreen()
            .tapLoginButtonSuccess()
        ProductList.ProductListScreen()
            .assertDisplayed(ProductList.ProductListScreen())
    }

    @MainActor
    func testSearchItemForDisplay()throws{
        Login.LoginScreen()
            .tapLoginButtonSuccess()
        ProductList.ProductListScreen()
            .assertDisplayed(ProductList.ProductListScreen())
            .tapSearchField("Red")
            .assert(\.searchItemFound, equals: 2, "Item is not found as expected")
    }
    
    @MainActor
    func testSearchItemSpecificProduct()throws{
        Login.LoginScreen()
            .tapLoginButtonSuccess()
        ProductList.ProductListScreen()
            .assertDisplayed(ProductList.ProductListScreen())
            .tapSearchField("Gucci")
            .tapProduct(matching: "Gucci")
            .assertDisplayed(ProductDetails.ProductDetailsScreen())
    }

}

