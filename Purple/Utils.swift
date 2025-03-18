//
//  Utils.swift
//  Purple
//
//  Created by Ben Booth on 3/14/25.
//

import Foundation
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
