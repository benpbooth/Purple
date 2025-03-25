//
//  NotificationsView.swift
//  Purple
//
//  Created by Ben Booth on 3/20/25.
//

import SwiftUI

struct NotificationsView: View {
    @State private var enablePushNotifications = true
    @State private var enableEmailAlerts = false

    var body: some View {
        Form {
            Toggle("Push Notifications", isOn: $enablePushNotifications)
            Toggle("Email Alerts", isOn: $enableEmailAlerts)
        }
        .navigationTitle("Notifications")
    }
}
