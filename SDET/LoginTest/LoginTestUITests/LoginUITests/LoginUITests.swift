//
//  LoginTestUITests.swift
//  LoginTestUITests
//
//  Created by Muhammad Mamun on 10/12/23.
//

import XCTest

final class LoginUITests: BaseXCTestSetup {
    
    @MainActor
    func testLoginWithValidCredentials()throws {
        Login.LoginScreen()
            .tapUserTextField(TestData.username)
            .tapPasswordTextField(TestData.password)
            .tapLoginButton()
            .assertDisplayed(ProductList.ProductListScreen())
    }
    
}


















//func testLoginWithInvalidCredentials() {
//    Login.LoginScreen()
//        .tapUserTextField("Mamun")
//        .tapPasswordTextField("dfuiu&")
//        .tapLoginButton()
//        .assert(\.loginFailedAlertToastShown, "Failed-login toast was not shown")
//}

//    @MainActor
//    func testLoginWithWrongUser() {
//        let login = Login.LoginScreen()
//            .tapUserTextField(TestData.wrongUsername)
//            .tapPasswordTextField(TestData.wrongPassword)
//            .tapLoginButton()
//        _ = login.loginFailedAlertToast
//        XCTAssertFalse(DashBoard.ProductScreen.isShownQuickly, "Dashboard must not appear for a wrong user")
//    }
