//
//  LoginAPI.swift
//  AuthenticationSwiftUI
//

import Foundation

enum LoginAPI: String {
    case loginRequest = "auth/login"

    static var getLoginRequestUrl: URL {
        guard let url = URL(string: APIConstants.basedURL + "/" + LoginAPI.loginRequest.rawValue) else {
            fatalError("Invalid URL format")
        }
        return url
    }
}
