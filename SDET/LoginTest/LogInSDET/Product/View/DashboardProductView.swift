//
//  DashboardProductView.swift
//  LoginTest
//

import SwiftUI

/// Home screen after login: bottom tab bar with Products and Cart.
struct DashboardProductView: View {

    @StateObject private var cart: CartViewModel
    private let service: ProductServiceProtocol

    init(service: ProductServiceProtocol, session: UserSessionProtocol = UserSession()) {
        self.service = service
        _cart = StateObject(wrappedValue: CartViewModel(session: session))
    }

    var body: some View {
        TabView {
            ProductListView(service: service, cart: cart)
                .tabItem { Label("Products", systemImage: "bag") }

            CartView(viewModel: cart)
                .tabItem { Label("Cart", systemImage: "cart") }
                .badge(cart.itemCount)      // number on the tab; hidden when 0
        }
    }
}
