import XCTest
@testable import LoginTest

/// Login screen logic: form rules, successful login, failed login.
@MainActor
final class LoginUnitTests: XCTestCase {

    func test_form_needsFiveCharUsernameAndSixCharPassword() {
        let sut = LoginViewModel(loginService: MockLoginService(result: .failure(NetworkError.invalidResponse)),
                                 session: FakeSession())
        XCTAssertFalse(sut.formIsValid)                 // empty

        sut.userName = "abcde"
        sut.password = "12345"                          // password one character short
        XCTAssertFalse(sut.formIsValid)

        sut.password = "123456"
        XCTAssertTrue(sut.formIsValid)
    }

    func test_login_success_returnsTrueAndRemembersUser() async throws {
        let session = FakeSession()
        let sut = LoginViewModel(loginService: MockLoginService(result: .success(try TestFixtures.response())),
                                 session: session)
        sut.userName = "emilys"
        sut.password = "emilyspass"

        let success = await sut.login()

        XCTAssertTrue(success)
        XCTAssertEqual(session.username, "emilys")
    }

    func test_login_failure_returnsFalseAndShowsFailureToast() async {
        let sut = LoginViewModel(loginService: MockLoginService(result: .failure(NetworkError.invalidResponse)),
                                 session: FakeSession())
        sut.userName = "emilys"
        sut.password = "wrongpass"

        let success = await sut.login()

        XCTAssertFalse(success)
        XCTAssertEqual(sut.toast, .failure)
    }
}
