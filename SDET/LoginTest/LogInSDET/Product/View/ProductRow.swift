//
//  ProductRow.swift
//  LoginTest
//

import SwiftUI

/// One row of the product list: picture, title and price.
struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: product.thumbnail)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)

            VStack(alignment: .leading) {
                Text(product.title).font(.headline)
                Text(String(format: "$%.2f", product.finalPrice)).foregroundColor(.secondary)
            }
        }
    }
}
