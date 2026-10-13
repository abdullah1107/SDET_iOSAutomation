//
//  LoginView.swift
//  AuthenticationSwiftUI
//
//  Created by Muhammad Mamun on 19/11/23.
//    userName: "kminchelle",
//    password: "0lelplR"

import Foundation
import SwiftUI


enum LoginScnerioAlert: String{
    case successLoginAlert = "You are now Successfully Login"
    case failedLoginAlert = "Please check your credentials and try again"
}

struct LoginView: View {
    
    @Binding var isLoggedIn: Bool
    @StateObject private var loginViewModel: LoginViewModel
    
    
    init(isLoggedIn: Binding<Bool>, loginViewModel: LoginViewModel) {
        _isLoggedIn = isLoggedIn
        _loginViewModel = StateObject(wrappedValue: loginViewModel)
    }
    
    var body: some View {
        ZStack {
            VStack {
                LoginLabelText()
                    .accessibility(identifier: "login")
                UserImage()
                    .accessibility(identifier: "loginIcon")
                UsernameTextField(username: $loginViewModel.userName)
                    .accessibility(identifier: "usernameField")
                PasswordSecureField(password: $loginViewModel.password)
                    .accessibility(identifier: "passwordField")
                
                Button(action: {
                    Task {
                        if await loginViewModel.login() {
                            isLoggedIn = true
                        }
                    }
                })
                {
                    if loginViewModel.isLoading {
                        ProgressView("Loading...")
                    } else {
                        LoginButtonContent(loginViewModel: loginViewModel)
                            .accessibility(identifier: "loginButton")
                    }
                }
                
                
            }.padding()
            
                .loginToast($loginViewModel.toast)
        }
    }
}


#Preview {
    LoginView(isLoggedIn: .constant(false), loginViewModel: LoginViewModel(loginService: LoginNetworkService()))
}


struct LoginLabelText: View {
    var body: some View {
        Text("Login User")
            .font(.largeTitle)
            .foregroundColor(.green)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
}

struct UserImage: View {
    var body: some View {
        Image("user")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 150)
            .clipped()
            .cornerRadius(150)
            .padding(.bottom, 30)
    }
}

struct LoginButtonContent: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        Text("LOGIN")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 250, height: 55)
            .cornerRadius(35.0)
            .background(Color.green)
            .opacity(buttonOpacity)
            .disabled(!loginViewModel.formIsValid)
    }
    
    var buttonOpacity: Double {
        return loginViewModel.formIsValid ? 1 : 0.5
     }
}

struct UsernameTextField: View {
  
    @Binding var username: String
    
    var body: some View {
        TextField("Username", text: $username)
            .padding()
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0))
            .cornerRadius(5.0)
            .padding(.bottom, 10)
    }
}

struct PasswordSecureField: View {
    
    @Binding var password: String
    
    var body: some View {
        SecureField("Password", text: $password)
            .padding()
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0))
            .cornerRadius(5.0)
            .padding(.bottom, 30)
    }
}



















// MARK: - Toast

enum LoginToast: Equatable {
    case success
    case failure

    var message: String {
        switch self {
        case .success: return LoginScnerioAlert.successLoginAlert.rawValue
        case .failure: return LoginScnerioAlert.failedLoginAlert.rawValue
        }
    }
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .failure: return "exclamationmark.triangle"
        }
    }
    var color: Color {
        switch self {
        case .success: return .green
        case .failure: return .red
        }
    }
    var identifier: String {
        switch self {
        case .success: return "loginSuccessToast"
        case .failure: return "loginFailedToast"
        }
    }
}

private struct ToastModifier: ViewModifier {
    @Binding var toast: LoginToast?
    var duration: TimeInterval

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let toast {
                Label(toast.message, systemImage: toast.icon)
                    .padding()
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(toast.color)
                    .cornerRadius(10)
                    .padding(.top)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .accessibilityIdentifier(toast.identifier)
                    .task(id: toast) {
                        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                        withAnimation { self.toast = nil }
                    }
            }
        }
        .animation(.easeInOut, value: toast)
    }
}

extension View {
    func loginToast(_ toast: Binding<LoginToast?>, duration: TimeInterval = 2) -> some View {
        modifier(ToastModifier(toast: toast, duration: duration))
    }
}
