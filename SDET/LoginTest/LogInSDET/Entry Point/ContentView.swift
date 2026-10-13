import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
              DashboardProductView(service: ProductNetworkService())
        } else {
            LoginView(isLoggedIn: $isLoggedIn, loginViewModel: LoginViewModel(loginService: LoginNetworkService()))
        }
    }
}

#Preview {
    ContentView()
}
