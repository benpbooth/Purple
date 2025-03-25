//
//  SettingsView.swift
//  Purple
//
//  Created by Ben Booth on 3/20/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section(header: Text("Account")) {
                NavigationLink("Profile", destination: ProfileView())  // ✅ Example
                NavigationLink("Change Password", destination: ChangePasswordView())
            }
            
            Section(header: Text("App Preferences")) {
                Toggle("Dark Mode", isOn: .constant(false))  // ✅ Example Toggle
                NavigationLink("Notifications", destination: NotificationsView())
            }
            
            Section(header: Text("Support")) {
                NavigationLink("Help Center", destination: HelpCenterView())
                NavigationLink("Report a Bug", destination: ReportBugView())
            }
            
            Section {
                Button(action: {
                    print("Logging out...")  // ✅ Replace with actual logout logic
                }) {
                    Text("Log Out")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Settings")
    }
}
