//
//  CartViewModel.swift
//  LoginTest
//

import Foundation
import Combine

/// What the Product Details screen needs from a cart.
protocol CartProtocol: AnyObject {
    func add(_ product: Product)
    /// e.g. "2 items in cart - User: emilys"
    var summaryText: String { get }
}

/// One cart shared by the Products tab (Add to Cart) and the Cart tab (list + totals).
@MainActor
final class CartViewModel: ObservableObject, CartProtocol {

    struct Line: Identifiable, Equatable {
        let product: Product
        var quantity: Int
        var id: Int { product.id }
    }

    @Published private(set) var lines: [Line] = []

    private let session: UserSessionProtocol

    init(session: UserSessionProtocol) {
        self.session = session
    }

    // MARK: - Actions

    func add(_ product: Product) {
        if let index = lines.firstIndex(where: { $0.id == product.id }) {
            lines[index].quantity += 1
        } else {
            lines.append(Line(product: product, quantity: 1))
        }
    }

    func remove(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {   // delete from the end so earlier indexes stay valid
            lines.remove(at: index)
        }
    }

    func clear() {
        lines.removeAll()
    }

    // MARK: - Text shown on screen

    /// The logged-in user ("Guest" when the app was opened without logging in).
    var username: String { session.username ?? "Guest" }

    var itemCount: Int { lines.reduce(0) { $0 + $1.quantity } }

    var itemCountText: String { "\(itemCount) item" + (itemCount == 1 ? "" : "s") }

    var totalText: String {
        String(format: "$%.2f", lines.reduce(0) { $0 + $1.product.finalPrice * Double($1.quantity) })
    }

    var summaryText: String { "\(itemCountText) in cart - User: \(username)" }
}
