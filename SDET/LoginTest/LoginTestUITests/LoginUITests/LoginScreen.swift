//
//  LoginScreen.swift
//  AuthenticationSwiftUIUITests
//
//  Created by Muhammad Mamun on 9/12/23.
//

import Foundation
import XCTest


extension Login {
    
    struct LoginScreen: Screen {
        var displayElement: XCUIElement { titleLabel }
        init() {
            waitForScreenDisplay(timeout: 10) // splash screen shows for ~3s first
        }
    }
}

fileprivate extension Login.LoginScreen {
    var titleLabel: XCUIElement { app.staticTexts["login"].firstMatch }
    var userNameTextField: XCUIElement { app.textFields["usernameField"].firstMatch }
    var passwordTextField: XCUIElement { app.secureTextFields["passwordField"].firstMatch }
    var loginButton: XCUIElement { app.buttons["loginButton"].firstMatch }
    var loginFailedToast: XCUIElement { app.staticTexts["loginFailedToast"].firstMatch }
  
}


extension Login.LoginScreen {
    
    @discardableResult
    func tapUserTextField(_ username:String) -> Self {
        userNameTextField.waitUntilDisplayed()
        userNameTextField.tap()
        userNameTextField.typeText(username)
        return self
    }

    @discardableResult
    func tapPasswordTextField(_ password:String) -> Self {
        passwordTextField.waitUntilDisplayed()
        passwordTextField.tap()
        passwordTextField.typeText(password)
        dismissKeyboardIfShown()
        return self
    }
    
    /// Tapping "Return" blindly fails when the software keyboard is not really on screen
    /// (hardware keyboard connected / keyboard still animating): the key's frame is below the screen
    /// and XCTest cannot scroll it into view. Only tap it when it is hittable.
    private func dismissKeyboardIfShown() {
        let returnKey = app.keyboards.buttons["Return"].firstMatch
        if returnKey.waitForExistence(timeout: 2), returnKey.isHittable {
            returnKey.tap()
        }
    }
    
    func dismissSavePasswordPromptIfShown() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        
        for candidate in [
            app.buttons["Not Now"].firstMatch,
            springboard.buttons["Not Now"].firstMatch
        ] {
            if candidate.waitForExistence(timeout: 3) {
                candidate.tap()
                return
            }
        }
    }

    @discardableResult
    func tapLoginButton() -> Self {
        loginButton.waitUntilDisplayed()
        loginButton.tap()
        dismissSavePasswordPromptIfShown()
        return self
    }
    
    var loginFailedAlertToastShown: Bool {
        loginFailedToast.waitUntilDisplayed(timeout: 10)
    }

    var loginFailedAlertToast: String {
        loginFailedToast.waitUntilDisplayed(timeout: 10)
        return loginFailedToast.label
    }
    
    @discardableResult
    func tapLoginButtonSuccess() -> ProductList.ProductListScreen {
        tapUserTextField(TestData.username)
        tapPasswordTextField(TestData.password)
        loginButton.waitUntilDisplayed()
        loginButton.tap()
        let dashboard = ProductList.ProductListScreen()
        dismissSavePasswordPromptIfShown()
        return dashboard
    }

}
