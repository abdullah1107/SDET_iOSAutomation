import SwiftUI

@main struct MyApp: App {
    init() {
        // UI tests pass "--uitesting" (always start logged out) and optionally
        // "--logged-in" (skip the login screen).
        
        let args = CommandLine.arguments
        if args.contains("--uitesting") {
            UserDefaults.standard.set(args.contains("--logged-in"), forKey: "isLoggedIn")
            UserSession().username = nil
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
