import XCTest
@testable import LoginTest

/// Product details logic: price text, stock text, Add to Cart.
@MainActor
final class ProductDetailUnitTests: XCTestCase {

    private func makeSUT(_ product: Product, cart: CartProtocol? = nil) -> ProductDetailViewModel {
        ProductDetailViewModel(product: product,
                               service: FakeProductService(),
                               cart: cart ?? CartViewModel(session: FakeSession()))
    }

    func test_priceText_appliesTheDiscount() {
        let sut = makeSUT(.sample(price: 100, discount: 10))

        XCTAssertEqual(sut.priceText, "$90.00")
        XCTAssertEqual(sut.originalPriceText, "$100.00")
    }

    func test_stockText_inStockAndOutOfStock() {
        XCTAssertEqual(makeSUT(.sample(stock: 5)).stockText, "In stock (5 left)")
        XCTAssertEqual(makeSUT(.sample(stock: 0)).stockText, "Out of stock")
    }

    func test_addToCart_showsItemCountAndUser() {
        let cart = CartViewModel(session: FakeSession(username: "emilys"))
        let sut = makeSUT(.sample(), cart: cart)

        sut.addToCart()

        XCTAssertEqual(sut.cartMessage, "1 item in cart - User: emilys")
    }
}
