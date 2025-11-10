//
//  AuthView.swift
//  SmartFit
//
//  Created by Edwin Yu
//

import SwiftUI

struct AuthView: View {
    @ObservedObject var authController: AuthenticationController
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Text("SmartFit")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)

            Spacer()

            VStack(spacing: 15) {
                if !isLoginMode {
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                }

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: handleAuth) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(isLoginMode ? "Login" : "Register")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .disabled(isLoading)

                Button(
                    action: { isLoginMode.toggle() },
                    label: {
                        Text(isLoginMode ? "Need an account? Register" : "Already have an account? Login")
                            .foregroundColor(.blue)
                    }
                )

                Button(action: handleGuestLogin) {
                    Text("Continue as Guest")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 30)

            Spacer()
        }
    }

    func handleAuth() {
        errorMessage = ""
        isLoading = true

        if isLoginMode {
            authController.login(email: email, password: password) { success, error in
                isLoading = false
                if !success {
                    errorMessage = error ?? "Login failed"
                }
            }
        } else {
            authController.register(name: name, email: email, password: password) { success, error in
                isLoading = false
                if !success {
                    errorMessage = error ?? "Registration failed"
                }
            }
        }
    }

    func handleGuestLogin() {
        authController.loginAsGuest()
    }
}
