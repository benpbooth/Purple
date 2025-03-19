//
//  ContentView.swift
//  Purple
//
//  Created by Ben Booth on 3/10/25.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView() // ✅ Make sure this is your real home screen
    }
}
struct DebugFontsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                Text("🔍 Available Fonts").font(.headline).padding(.bottom, 5)

                ForEach(UIFont.familyNames.sorted(), id: \.self) { family in
                    VStack(alignment: .leading) {
                        Text("🔹 \(family)").bold()
                        ForEach(UIFont.fontNames(forFamilyName: family).sorted(), id: \.self) { fontName in
                            Text("  - \(fontName)")
                        }
                    }
                    .padding(.bottom, 5)
                }
            }
            .padding()
        }
        .onAppear {
            print("📢 Available Fonts:")
            for family in UIFont.familyNames.sorted() {
                print("🔹 \(family)")
                for fontName in UIFont.fontNames(forFamilyName: family).sorted() {
                    print("  - \(fontName)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
