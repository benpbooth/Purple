//
//  LoginView.swift
//  Purple
//
//  Created by Ben Booth on 3/10/25.
//
import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack(spacing: 20) {
            
            Spacer()
            
            // Purple Logo (Keeping this unchanged)
            Image("purpleLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 275) // Adjust as needed
            
            // Email or Username Input
            Image("emailOrUsername")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 50) // Match input field size
            
            // Password Input
            Image("password")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 50)
            
            // Sign In Button
            Button(action: {
                print("Sign In tapped")
            }) {
                Image("signIn")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 50)
                    .padding(.top, 25)
            }
            
            // Sign Up Button
            Button(action: {
                print("Sign Up tapped")
            }) {
                Image("signUp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 50)
                    .padding(.top, -20)
            }
            
            // Social Links (Facebook, Google, X)
            Image("socialLinks")
                .resizable()
                .scaledToFit()
                .frame(width: 250) // Adjust size to fit layout
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white) // Light gray background
    }
}

// Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
