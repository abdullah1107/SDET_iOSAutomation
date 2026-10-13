//
//  ProductDetailView.swift
//  LoginTest
//

import SwiftUI

/// One product: image, title, price, rating, stock and description.
struct ProductDetailView: View {

    @StateObject private var viewModel: ProductDetailViewModel

    init(viewModel: ProductDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                AsyncImage(url: viewModel.imageURL) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, minHeight: 250)

                Text(viewModel.product.title)
                    .font(.title.bold())
                    .accessibilityIdentifier("productDetailsIdentifier")

                if let brand = viewModel.product.brand {
                    Text(brand).foregroundColor(.secondary)
                }

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(viewModel.priceText)
                        .font(.largeTitle.bold())
                        .foregroundColor(.green)
                        .accessibilityIdentifier("productPrice")
                    if viewModel.hasDiscount {
                        Text(viewModel.originalPriceText).strikethrough().foregroundColor(.secondary)
                    }
                }

                Text(viewModel.ratingText)
                Text(viewModel.stockText)

                Button {
                    viewModel.addToCart()
                } label: {
                    Label("Add to Cart", systemImage: "cart.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("addToCartButton")

                if let cartMessage = viewModel.cartMessage {
                    Text(cartMessage)
                        .font(.subheadline.bold())
                        .foregroundColor(.green)
                        .accessibilityIdentifier("cartSummary")
                }

                Text(viewModel.product.description)
                    .accessibilityIdentifier("productDescription")

                if let message = viewModel.errorMessage {
                    Text(message).foregroundColor(.red).accessibilityIdentifier("productDetailsError")
                }
            }
            .padding()
        }
        .navigationTitle("Product")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}
