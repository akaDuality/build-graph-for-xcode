//
//  UISettings.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 26.10.2021.
//

import Foundation

class UISettings {
    @Storage(key: "showSubtask", defaultValue: false)
    var showSubtask: Bool
    
    @Storage(key: "showLinks", defaultValue: false)
    var showLinks: Bool
    
    @Storage(key: "showPerformance", defaultValue: false)
    var showPerformance: Bool
}

@propertyWrapper
struct Storage<T> {
    private let key: String
    private let defaultValue: T
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
