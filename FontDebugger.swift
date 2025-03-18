//
//  FontDebugger.swift
//  Purple
//
//  Created by Ben Booth on 3/18/25.
//

import SwiftUI

struct FontDebugger {
    static func printAvailableFonts() {
        for family in UIFont.familyNames.sorted() {
            print("🖋 FONT FAMILY: \(family)")
            for fontName in UIFont.fontNames(forFamilyName: family) {
                print("   ├─ \(fontName)")
            }
        }
    }
}
