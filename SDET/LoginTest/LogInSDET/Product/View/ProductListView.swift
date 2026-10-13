//
//  ProductListView.swift
//  LoginTest
//

import SwiftUI

/// Products tab: a searchable list. Tap a row to see the product details.
struct ProductListView: View {

    @StateObject private var viewModel: ProductListViewModel
    private let service: ProductServiceProtocol
    private let cart: CartProtocol

    init(service: ProductServiceProtocol, cart: CartProtocol) {
        self.service = service
        self.cart = cart
        _viewModel = StateObject(wrappedValue: ProductListViewModel(service: service))
    }

    var body: some View {
        NavigationStack {
            List(viewModel.filteredProducts) { product in
                NavigationLink {
                    ProductDetailView(viewModel: ProductDetailViewModel(product: product, service: service, cart: cart))
                } label: {
                    ProductRow(product: product)
                }
                .accessibilityIdentifier("productCellItem_\(product.id)")
                .task { await viewModel.loadMoreIfNeeded(current: product) }   // next page at the last row
            }
            .overlay {
                if let message = viewModel.errorMessage { Text(message) }
            }
            .searchable(text: $viewModel.searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search Product")
            .navigationTitle("Dashboard")
            .task { await viewModel.loadProducts() }
        }
    }
}
