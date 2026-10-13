//
//  NetworkRequestError.swift
//  AuthenticationSwiftUI
//

import Foundation

enum NetworkError: Error, Equatable {
    case encodeFailed
    case invalidResponse
    case decodeFailed
    case invalidURL
}
