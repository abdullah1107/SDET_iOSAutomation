import XCTest
@testable import LoginTest

/// Product list (Dashboard) logic: loading, search, error.
@MainActor
final class ProductListUnitTests: XCTestCase {

    private let threeProducts = [Product.sample(id: 1, title: "Red Lipstick"),
                                 Product.sample(id: 2, title: "Phone"),
                                 Product.sample(id: 3, title: "Red Nail Polish")]

    func test_loadProducts_fillsTheList() async {
        let sut = ProductListViewModel(service: FakeProductService(products: threeProducts))

        await sut.loadProducts()

        XCTAssertEqual(sut.products.count, 3)
    }

    func test_search_keepsOnlyMatchingTitles() async {
        let sut = ProductListViewModel(service: FakeProductService(products: threeProducts))
        await sut.loadProducts()

        sut.searchText = "red"

        XCTAssertEqual(sut.filteredProducts.map(\.title), ["Red Lipstick", "Red Nail Polish"])
    }

    func test_loadProducts_failure_showsErrorMessage() async {
        let sut = ProductListViewModel(service: FakeProductService(shouldFail: true))

        await sut.loadProducts()

        XCTAssertTrue(sut.products.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
    }
}
