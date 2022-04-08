//
//  Storage.swift
//  
//
//  Created by Mikhail Rubanov on 08.04.2022.
//

import Foundation

@propertyWrapper
public struct Storage<T> {
    private let key: String
    private let defaultValue: T
    
    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    let userDefaults = UserDefaults.standard
    
    public var wrappedValue: T {
        get {
            return userDefaults
                .object(forKey: key) as? T ?? defaultValue
        }
        set {
            userDefaults
                .set(newValue, forKey: key)
        }
    }
}
