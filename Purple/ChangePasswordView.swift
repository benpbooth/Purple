//
//  ChangePasswordView.swift
//  Purple
//
//  Created by Ben Booth on 3/20/25.
//

import SwiftUI

struct ChangePasswordView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    var body: some View {
        Form {
            Section(header: Text("Change Password")) {
                SecureField("Current Password", text: $currentPassword)
                SecureField("New Password", text: $newPassword)
                SecureField("Confirm New Password", text: $confirmPassword)
                
                Button("Update Password") {
                    print("Password updated!") // Replace with actual logic
                }
                .foregroundColor(.blue)
            }
        }
        .navigationTitle("Change Password")
    }
}
