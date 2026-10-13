//
//  WireMockClient.swift
//  LoginTest
//
//  Minimal WireMock client for the login flow. Start WireMock first:
//      java -jar wiremock-standalone-<version>.jar --port 8080
//
//  The request to match and the response to send are Codable models,
//  so JSONEncoder builds the mapping JSON (and JSONDecoder reads WireMock's answers).
//

import Foundation

// MARK: - Models: the login call (same JSON the app sends and dummyjson returns)

/// REQUEST body the app sends to POST /auth/login.
struct LoginCredentials: Codable {
    let username: String
    let password: String
}

/// RESPONSE body for a successful login.
struct LoginUserResponse: Codable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let gender: String
    let image: String
    let accessToken: String
    let refreshToken: String
}

// MARK: - Models: how WireMock describes a mapping

/// A mapping = the REQUEST to match + the RESPONSE to send back.
struct WireMockMapping<Request: Encodable, Response: Encodable>: Encodable {
    var priority = 5                 // smaller number is checked first
    let request: Request
    let response: Response
}

/// REQUEST: POST /auth/login whose JSON body contains these fields.
struct LoginRequestPattern: Encodable {
    struct BodyPattern: Encodable {
        let equalToJson: LoginCredentials
        var ignoreExtraElements = true
    }
    var method = "POST"
    var url = "/auth/login"
    let bodyPatterns: [BodyPattern]

    init(credentials: LoginCredentials) {
        bodyPatterns = [BodyPattern(equalToJson: credentials)]
    }
}

/// RESPONSE: this status and this JSON body.
struct JSONResponse<Body: Encodable>: Encodable {
    let status: Int
    var headers = ["Content-Type": "application/json"]
    let jsonBody: Body
}

/// REQUEST: any URL.
struct AnyRequestPattern: Encodable {
    var urlPattern = ".*"
}

/// RESPONSE: ask another server and return its answer.
struct ProxyResponse: Encodable {
    let proxyBaseUrl: String
}


// MARK: - Client

struct WireMockClient {

    let baseURL = ProcessInfo.processInfo.environment["WIREMOCK_URL"] ?? "http://localhost:8080"

    /// POST /auth/login with this username + password  ->  200 and a token.
    /// Any other credentials match nothing, so WireMock answers 404 and the app shows "login failed".
    func stubValidLogin(username: String, password: String) throws {
        let user = LoginUserResponse(id: 1, username: username, email: "\(username)@example.com",
                                 firstName: "Test", lastName: "User", gender: "female",
                                 image: "https://dummyjson.com/icon/\(username)/128",
                                 accessToken: "wiremock-access-token", refreshToken: "wiremock-refresh-token")
        try send("/__admin/mappings", WireMockMapping(
            request: LoginRequestPattern(credentials: LoginCredentials(username: username, password: password)),
            response: JSONResponse(status: 200, jsonBody: user)))
    }

    /// Only the login is mocked: every other call (products...) is passed on to the real API.
    func passEverythingElseToRealAPI() throws {
        try send("/__admin/mappings", WireMockMapping(
            priority: 10,            // the login mapping (priority 5) is checked first
            request: AnyRequestPattern(),
            response: ProxyResponse(proxyBaseUrl: "https://dummyjson.com")))
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    /// How many times the app called POST /auth/login.
    func loginCalls() throws -> Int {
        struct Count: Decodable { let count: Int }
        struct Query: Encodable { let method: String; let url: String }
        let reply = try send("/__admin/requests/count", Query(method: "POST", url: "/auth/login"))
        return try JSONDecoder().decode(Count.self, from: reply).count
    }

    /// Removes all mappings and recorded requests.
    func reset() throws { try send("/__admin/reset", [String: String]()) }

    var isRunning: Bool { (try? reset()) != nil }

    // MARK: - HTTP

    @discardableResult
    private func send<Body: Encodable>(_ path: String, _ body: Body) throws -> Data {
        var request = URLRequest(url: URL(string: baseURL + path)!, timeoutInterval: 5)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var outcome: Result<Data, Error> = .failure(URLError(.cannotConnectToHost))
        let finished = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data, let status = (response as? HTTPURLResponse)?.statusCode, status < 300 {
                outcome = .success(data)
            } else if let error {
                outcome = .failure(error)
            }
            finished.signal()
        }.resume()
        finished.wait()
        return try outcome.get()
    }
}
