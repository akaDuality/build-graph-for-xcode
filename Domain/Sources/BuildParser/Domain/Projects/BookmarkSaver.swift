//
//  BookmarkSaver.swift
//  
//
//  Created by Mikhail Rubanov on 06.03.2022.
//

import Foundation

class BookmarkSaver {
    let userDefaults = UserDefaults.standard
    
    func saveDerivedDataBookmark(data: Data) {
        userDefaults.set(data, forKey: "derivedDataBookmark")
    }
    
    func derivedDataBookmark() -> Data? {
        userDefaults.value(forKey: "derivedDataBookmark") as? Data
    }
    
    // TODO: Union with UISettings
}
