//
//  UserSession.swift
//  LoginTest
//

import Foundation

/// Remembers who is logged in (set at login, read by the Cart screen).
protocol UserSessionProtocol: AnyObject {
    var username: String? { get set }
}

final class UserSession: UserSessionProtocol {

    private let defaults: UserDefaults
    private let key = "loggedInUsername"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var username: String? {
        get { defaults.string(forKey: key) }
        set { defaults.set(newValue, forKey: key) }
    }
}
