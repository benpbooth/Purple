//
//  ReportBugView.swift
//  Purple
//
//  Created by Ben Booth on 3/20/25.
//

import SwiftUI

struct ReportBugView: View {
    @State private var bugDescription = ""

    var body: some View {
        Form {
            Section(header: Text("Report a Bug")) {
                TextField("Describe the issue...", text: $bugDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Submit") {
                    print("Bug report submitted!") // Replace with actual logic
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Report a Bug")
    }
}
