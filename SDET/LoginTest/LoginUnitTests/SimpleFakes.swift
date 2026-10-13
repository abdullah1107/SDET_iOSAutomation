//
//  SimpleFakes.swift
//  LoginTestTests
//
//  Tiny stand-ins used by the unit tests (no network, no UserDefaults).
//

import Foundation
@testable import LoginTest

extension Product {
    /// A product with only the values a test cares about.
    static func sample(id: Int = 1, title: String = "Phone", price: Double = 100,
                       discount: Double = 0, stock: Int = 5) -> Product {
        Product(id: id, title: title, description: "", category: "test", price: price,
                discountPercentage: discount, rating: 4.5, stock: stock, brand: nil,
                images: [], thumbnail: "")
    }
}

/// Remembers the username in memory.
final class FakeSession: UserSessionProtocol {
    var username: String?
    init(username: String? = nil) { self.username = username }
}

/// Returns the given products (or throws) instead of calling the API.
struct FakeProductService: ProductServiceProtocol {
    var products: [Product] = []
    var shouldFail = false

    func fetchProducts(limit: Int, skip: Int) async throws -> [Product] {
        if shouldFail { throw NetworkError.invalidResponse }
        return Array(products.dropFirst(skip).prefix(limit))
    }

    func fetchProduct(id: Int) async throws -> Product {
        if shouldFail { throw NetworkError.invalidResponse }
        return products.first { $0.id == id } ?? .sample(id: id)
    }
}
