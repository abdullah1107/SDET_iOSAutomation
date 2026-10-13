//
//  LoginViewModel.swift
//  AuthenticationSwiftUI
//
//  Created by Muhammad Mamun on 28/11/23.
//

import Foundation
import Combine

/// @MainActor: every @Published property is touched on the main thread.
/// The network call is awaited, so URLSession runs off-main and we resume on main automatically.
/// 
@MainActor
final class LoginViewModel: ObservableObject, LoginProtocol {

    @Published var userName: String = ""
    @Published var password: String = ""
    @Published private(set) var isLoading = false
    @Published var toast: LoginToast?

    private let loginService: LoginProtocol
    private let session: UserSessionProtocol


    init(loginService: LoginProtocol, session: UserSessionProtocol? = nil) {
        self.loginService = loginService
        self.session = session ?? UserSession()
    }

    var formIsValid: Bool {
        userName.count >= 5 && password.count >= 6
    }

    /// LoginProtocol: delegates to the injected service.
    func login(user: LoginUser) async throws -> LoginUserResponse {
        try await loginService.login(user: user)
    }

 
    func login() async -> Bool {
        guard !isLoading else { return false }
        guard !userName.isEmpty, !password.isEmpty else {
            toast = .failure
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await login(user: LoginUser(userName: userName, password: password))
            session.username = response.username   // the Cart screen shows who is logged in
            toast = .success
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            return true
        } catch {
            toast = .failure
            return false
        }
    }
}
