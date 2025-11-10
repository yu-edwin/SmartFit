//
//  SettingsView.swift
//  SmartFit
//
//  Created by Edwin Yu
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authController: AuthenticationController

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    if let user = authController.currentUser {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.gray)
                        }

                        if let name = user.name {
                            HStack {
                                Text("Name")
                                Spacer()
                                Text(name)
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                Button(
                    action: {
                        authController.signOut()
                    },
                    label: {
                        HStack {
                            Text("Sign Out")
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(.red)
                        }
                    })
                }
            }
            .navigationTitle("Settings")
        }
    }
}
