//
//  APIConstants.swift
//  AuthenticationSwiftUI
//

import Foundation

enum APIConstants {
    /// UI tests can point the app at another server (e.g. a local mock) via the BASE_URL launch environment.
    static let basedURL = ProcessInfo.processInfo.environment["BASE_URL"] ?? "https://dummyjson.com"
}
