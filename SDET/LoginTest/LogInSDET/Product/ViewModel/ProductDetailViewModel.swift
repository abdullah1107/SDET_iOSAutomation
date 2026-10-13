//
//  ProductDetailViewModel.swift
//  LoginTest
//

import Foundation
import Combine

/// State for the product details screen. Starts with the list item, then refreshes it from the service.
@MainActor
final class ProductDetailViewModel: ObservableObject {

    @Published private(set) var product: Product
    @Published private(set) var errorMessage: String?
    /// Shown after "Add to Cart": how many items are in the cart and which user it belongs to.
    @Published private(set) var cartMessage: String?

    private let service: ProductServiceProtocol
    private let cart: CartProtocol

    init(product: Product, service: ProductServiceProtocol, cart: CartProtocol) {
        self.product = product
        self.service = service
        self.cart = cart
    }

    func addToCart() {
        cart.add(product)
        cartMessage = cart.summaryText
    }

    func load() async {
        do {
            product = try await service.fetchProduct(id: product.id)
            errorMessage = nil
        } catch {
            errorMessage = "Could not refresh this product."
        }
    }

    // MARK: - Text shown on screen

    var hasDiscount: Bool { product.discountPercentage > 0 }
    var priceText: String { Self.money(product.finalPrice) }
    var originalPriceText: String { Self.money(product.price) }
    var ratingText: String { String(format: "Rating %.1f / 5", product.rating) }
    var stockText: String { product.stock > 0 ? "In stock (\(product.stock) left)" : "Out of stock" }
    var imageURL: URL? { URL(string: product.images.first ?? product.thumbnail) }

    private static func money(_ value: Double) -> String { String(format: "$%.2f", value) }
}
