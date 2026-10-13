//
//  WireMockLoginTests.swift
//  LoginTest
//

import XCTest

/// Login against WireMock instead of dummyjson.
/// Start WireMock first:  java -jar wiremock-standalone-<version>.jar --port 8080
/// Run: python3 tools/main.py --test LoginTestUITests/WireMockLoginTests
final class WireMockLoginTests: BaseXCTestSetup {

    private let wireMock = WireMockClient()

    override var baseURLOverride: String? { wireMock.baseURL }   // the app talks to WireMock

    override func prepareMocks() throws {
        try XCTSkipUnless(wireMock.isRunning, "WireMock is not running at \(wireMock.baseURL)")
        try wireMock.reset()
        try wireMock.stubValidLogin(username: TestData.username, password: TestData.password)
        try wireMock.passEverythingElseToRealAPI()   // products still come from the real API
    }

    @MainActor
    func testValidUserLoginThroughWireMock() throws {
        Login.LoginScreen()
            .tapLoginButtonSuccess()
            .assertDisplayed(ProductList.ProductListScreen())

        XCTAssertEqual(try wireMock.loginCalls(), 1, "The app should call POST /auth/login once, through WireMock")
    }
}
