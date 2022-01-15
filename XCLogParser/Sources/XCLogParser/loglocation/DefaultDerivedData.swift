//
//  DefaultDerivedData.swift
//  
//
//  Created by Mikhail Rubanov on 09.01.2022.
//

import Foundation

public class DefaultDerivedData {
    
    public init() {}
    
    private func getCustomDerivedDataDir() -> URL? {
        guard let xcodeOptions = UserDefaults.standard.persistentDomain(forName: "com.apple.dt.Xcode") else {
            return nil
        }
        guard let customLocation = xcodeOptions["IDECustomDerivedDataLocation"] as? String else {
            return nil
        }
        return URL(fileURLWithPath: customLocation)
    }
    
    public func getDerivedDataDir() -> URL? {
        if let customDerivedDataDir = getCustomDerivedDataDir() {
            return customDerivedDataDir
        }
        
        return defaultDerivedData
    }
    
    var defaultDerivedData: URL? {
        guard let homeDirURL = URL.homeDir else {
            return nil
        }
        return homeDirURL.appendingPathComponent("Library/Developer/Xcode/DerivedData", isDirectory: true)
    }
}
