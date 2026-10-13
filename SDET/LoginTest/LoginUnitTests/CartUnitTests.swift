import XCTest
@testable import LoginTest

/// Cart logic: item count, lines, total, user.
@MainActor
final class CartUnitTests: XCTestCase {

    func test_sameProductTwice_isOneLineWithQuantityTwo() {
        let sut = CartViewModel(session: FakeSession())

        sut.add(.sample(id: 1))
        sut.add(.sample(id: 1))

        XCTAssertEqual(sut.lines.count, 1)
        XCTAssertEqual(sut.itemCount, 2)
    }

    func test_twoProducts_countAndTotal() {
        let sut = CartViewModel(session: FakeSession())

        sut.add(.sample(id: 1, price: 10))
        sut.add(.sample(id: 2, price: 5.50))

        XCTAssertEqual(sut.itemCountText, "2 items")
        XCTAssertEqual(sut.totalText, "$15.50")
    }

    func test_username_comesFromTheSession_orGuest() {
        XCTAssertEqual(CartViewModel(session: FakeSession(username: "emilys")).username, "emilys")
        XCTAssertEqual(CartViewModel(session: FakeSession()).username, "Guest")
    }
}
