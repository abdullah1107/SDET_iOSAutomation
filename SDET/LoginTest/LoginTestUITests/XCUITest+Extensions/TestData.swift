import Foundation

/// Values injected by `python3 tools/main.py` (xcodebuild forwards TEST_RUNNER_<NAME> as <NAME>).
/// Falls back to the dummyjson defaults so tests still run straight from Xcode.
enum TestData {
    private static func env(_ key: String, _ fallback: String) -> String {
        ProcessInfo.processInfo.environment[key] ?? fallback
    }

    static var baseURL: String? { ProcessInfo.processInfo.environment["BASE_URL"] }
    /// The RIGHT user picked from Users.json by tools/main.py.
    static var username: String { env("LOGIN_USERNAME", "emilys") }
    static var password: String { env("LOGIN_PASSWORD", "emilyspass") }
    /// The WRONG user picked from InvalidUsers.json by tools/main.py.
    static var wrongUsername: String { env("WRONG_USERNAME", "not-a-user") }
    static var wrongPassword: String { env("WRONG_PASSWORD", "wrong-password") }
    static var unknownUsername: String { env("UNKNOWN_USERNAME", "not-a-user") }
}
