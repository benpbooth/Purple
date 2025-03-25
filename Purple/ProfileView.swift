//
//  ProfileView.swift
//  Purple
//
//  Created by Ben Booth on 3/20/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Text("Profile Settings")
                .font(.largeTitle)
                .padding()
            Text("User profile details will go here.")
                .foregroundColor(.gray)
        }
        .navigationTitle("Profile")
    }
}
