//
//  HelpCenterView.swift
//  Purple
//
//  Created by Ben Booth on 3/20/25.
//
import SwiftUI

struct HelpCenterView: View {
    var body: some View {
        VStack {
            Text("Help Center")
                .font(.largeTitle)
                .padding()
            Text("FAQs, contact support, and troubleshooting info.")
                .foregroundColor(.gray)
        }
        .navigationTitle("Help Center")
    }
}
