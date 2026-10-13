import Foundation
@testable import LoginTest

nonisolated enum TestFixtures {
    static let loginJSON = """
    {"id":1,"username":"emilys","email":"emily@x.com","firstName":"Emily","lastName":"Johnson",
     "gender":"female","image":"https://x/y.png","accessToken":"ACCESS","refreshToken":"REFRESH"}
    """

    static func response() throws -> LoginUserResponse {
        try JSONDecoder().decode(LoginUserResponse.self, from: Data(loginJSON.utf8))
    }
}

/// Returns a canned result and records every call.
final class MockLoginService: LoginProtocol {
    var result: Result<LoginUserResponse, Error>
    private(set) var receivedUsers: [LoginUser] = []

    init(result: Result<LoginUserResponse, Error>) {
        self.result = result
    }

    func login(user: LoginUser) async throws -> LoginUserResponse {
        receivedUsers.append(user)
        return try result.get()
    }
}

/// Suspends inside login() until `release()` so tests can observe the loading state.
final class GatedLoginService: LoginProtocol {
    private var continuation: CheckedContinuation<Void, Never>?
    private(set) var callCount = 0

    func login(user: LoginUser) async throws -> LoginUserResponse {
        callCount += 1
        await withCheckedContinuation { continuation = $0 }
        return try TestFixtures.response()
    }

    func release() {
        continuation?.resume()
        continuation = nil
    }
}

/// Intercepts URLSession traffic so no real network is used.
nonisolated final class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    /// The last request that went through, so tests can check the URL that was called.
    nonisolated(unsafe) static var lastRequest: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        MockURLProtocol.lastRequest = request
        guard let handler = MockURLProtocol.handler else { return }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

extension URLRequest {
    /// URLProtocol receives the body as a stream, not `httpBody`.
    func bodyData() -> Data? {
        if let httpBody { return httpBody }
        guard let stream = httpBodyStream else { return nil }
        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 1024)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            if count <= 0 { break }
            data.append(buffer, count: count)
        }
        return data
    }
}
