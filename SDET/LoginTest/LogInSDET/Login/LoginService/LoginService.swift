//
//  LoginService.swift
//  AuthenticationSwiftUI
//
//  Created by Muhammad Mamun on 20/11/23.
//

import Foundation

/// Contract for anything that can perform a login (real network service, view model, test mock).
protocol LoginProtocol {
    func login(user: LoginUser) async throws -> LoginUserResponse
}

/// Network implementation. Uses async/await; URLSession does the work off the main thread.
struct LoginNetworkService: LoginProtocol {

    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func login(user: LoginUser) async throws -> LoginUserResponse {
        var request = URLRequest(url: LoginAPI.getLoginRequestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(user)
        } catch {
            throw NetworkError.encodeFailed
        }

        let (data, response) = try await urlSession.data(for: request)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NetworkError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(LoginUserResponse.self, from: data)
        } catch {
            throw NetworkError.decodeFailed
        }
    }
}
