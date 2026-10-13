//
//  CartView.swift
//  LoginTest
//

import SwiftUI

/// Cart tab: who the cart belongs to, how many items, and the items.
struct CartView: View {

    @ObservedObject var viewModel: CartViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("User: \(viewModel.username)")
                        .accessibilityIdentifier("cartUserLabel")
                    Text("Items in cart: \(viewModel.itemCount)")
                        .accessibilityIdentifier("cartItemCountLabel")
                }

                Section("Items") {
                    ForEach(viewModel.lines) { line in
                        HStack {
                            Text(line.product.title)
                            Spacer()
                            Text("x\(line.quantity)")
                            Text(String(format: "$%.2f", line.product.finalPrice * Double(line.quantity)))
                                .bold()
                        }
                        .accessibilityIdentifier("cartLine_\(line.id)")
                    }
                    .onDelete { viewModel.remove(at: $0) }
                }

                if !viewModel.lines.isEmpty {
                    Section {
                        HStack {
                            Text("Total").bold()
                            Spacer()
                            Text(viewModel.totalText).bold()
                        }
                        .accessibilityIdentifier("cartTotalLabel")
                    }
                }
            }
            .overlay {
                if viewModel.lines.isEmpty {
                    Text("Your cart is empty").foregroundColor(.secondary)
                        .accessibilityIdentifier("cartEmptyLabel")
                }
            }
            .navigationTitle("Cart")
        }
    }
}
