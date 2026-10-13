//
//  LoginUser.swift
//  HandlingGCD
//

import Foundation

nonisolated struct LoginUser: Encodable {
    let userName: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case userName = "username"
        case password
    }
}

nonisolated struct LoginUserResponse: Decodable {
    let id: Int
    let username, email, firstName, lastName: String
    let gender: String
    let image: String
    /// Auth token. dummyjson now returns it as `accessToken`; older responses used `token`.
    let token: String
    let refreshToken: String?

    private enum CodingKeys: String, CodingKey {
        case id, username, email, firstName, lastName, gender, image
        case token, accessToken, refreshToken
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        username = try c.decode(String.self, forKey: .username)
        email = try c.decode(String.self, forKey: .email)
        firstName = try c.decode(String.self, forKey: .firstName)
        lastName = try c.decode(String.self, forKey: .lastName)
        gender = try c.decode(String.self, forKey: .gender)
        image = try c.decode(String.self, forKey: .image)
        if let access = try c.decodeIfPresent(String.self, forKey: .accessToken) {
            token = access
        } else {
            token = try c.decode(String.self, forKey: .token)
        }
        refreshToken = try c.decodeIfPresent(String.self, forKey: .refreshToken)
    }
}
