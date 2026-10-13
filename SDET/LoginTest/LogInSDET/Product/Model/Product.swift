//
//  Product.swift
//  LoginTest
//

import Foundation

/// One product from https://dummyjson.com/products (list item and detail share this shape).
nonisolated struct Product: Decodable, Identifiable, Equatable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let brand: String?          // a few products have no brand
    let images: [String]
    let thumbnail: String
}

/// Response of GET /products?limit=&skip=
nonisolated struct ProductList: Decodable {
    let products: [Product]
}

nonisolated extension Product {
    /// Price after the discount (equals `price` when there is no discount).
    var finalPrice: Double { price * (1 - discountPercentage / 100) }
}
