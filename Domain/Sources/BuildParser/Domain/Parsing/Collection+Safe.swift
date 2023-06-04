//
//  Collection+Safe.swift
//  BuildParser
//
//  Created by Mikhail Rubanov on 20.05.2022.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
