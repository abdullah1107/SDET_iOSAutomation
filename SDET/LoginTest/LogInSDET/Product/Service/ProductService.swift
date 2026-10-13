//
//  ProductService.swift
//  LoginTest
//

import Foundation

/// Contract for anything that can load products (real network service, test mock).
protocol ProductServiceProtocol {
    func fetchProducts(limit: Int, skip: Int) async throws -> [Product]
    func fetchProduct(id: Int) async throws -> Product
}

/// Network implementation. Same style as LoginNetworkService: async/await over URLSession.
struct ProductNetworkService: ProductServiceProtocol {

    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func fetchProducts(limit: Int, skip: Int) async throws -> [Product] {
        let list: ProductList = try await get("/products?limit=\(limit)&skip=\(skip)")
        return list.products
    }

    func fetchProduct(id: Int) async throws -> Product {
        try await get("/products/\(id)")
    }

    /// One GET helper for every endpoint: build URL -> call -> check status -> decode.
    private func get<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: APIConstants.basedURL + path) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await urlSession.data(from: url)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NetworkError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodeFailed
        }
    }
}
