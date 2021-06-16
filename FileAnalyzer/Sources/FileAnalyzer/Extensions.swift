//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 16.06.2021.
//

import Foundation

extension Dictionary where Key: Comparable {
    func iterateAlphabetically( _ block: (_ key: Key, _ value: Value) -> Void) {
        for key in keys.sorted(by: <) {
            let value = self[key]!
            block(key, value)
        }
    }
}

extension FileManager {
    
    func directoryExists(_ atPath: String) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: atPath, isDirectory:&isDirectory)
        return exists && isDirectory.boolValue
    }
}

extension URL {
    var fileName: String {
        pathComponents.last!
    }
}

extension String {
    var digit: Int? {
        Int(self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}
