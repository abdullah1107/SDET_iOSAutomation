//
//  ProductListViewModel.swift
//  LoginTest
//

import Foundation
import Combine

/// State for the Dashboard (product list). Talks to the service only through ProductServiceProtocol.
@MainActor
final class ProductListViewModel: ObservableObject {

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var searchText = ""

    private let service: ProductServiceProtocol
    private let pageSize = 10
    private var hasMore = true

    init(service: ProductServiceProtocol) {
        self.service = service
    }

    /// Search runs on the products already loaded.
    var filteredProducts: [Product] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return products }
        return products.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    /// Loads the next page (the first page when the list is empty).
    func loadProducts() async {
        guard !isLoading, hasMore else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let page = try await service.fetchProducts(limit: pageSize, skip: products.count)
            products.append(contentsOf: page)
            hasMore = page.count == pageSize
        } catch {
            errorMessage = "Could not load products. Please try again."
        }
    }

    /// Call when a row appears; loads the next page once the last row is reached.
    func loadMoreIfNeeded(current product: Product) async {
        guard product.id == products.last?.id else { return }
        await loadProducts()
    }
}
