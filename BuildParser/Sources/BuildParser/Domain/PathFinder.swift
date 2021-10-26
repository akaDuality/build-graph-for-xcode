//
//  PathFinder.swift
//  
//
//  Created by Mikhail Rubanov on 25.10.2021.
//

import Foundation
import XCLogParser
import Foundation

public class PathFinder {
    let logOptions: LogOptions
    public init(logOptions: LogOptions) {
        self.logOptions = logOptions
    }
    
    let logFinder = LogFinder()
    
    public func buildGraphURL() throws -> URL {
        //        let depsURL = Bundle.main.url(forResource: "targetGraph-Tuist", withExtension: "txt")!
        URL(string: "file:///Users/rubanov/Library/Developer/Xcode/DerivedData/DodoPizzaTuist-fmlmdqfbrolxgjanbelteljkwvns/Build/Intermediates.noIndex/XCBuildData/cc30cdd1103f0028351f2dccedb15e35-targetGraph.txt")!
//    file:///Users/rubanov/Library/Developer/Xcode/DerivedData/DodoPizzaTuist-fmlmdqfbrolxgjanbelteljkwvns/Logs/Build/D3600AB8-9210-46D4-9DD6-6F1D8D9D9083.xcactivitylog
//    file:///Users/rubanov/Library/Developer/Xcode/DerivedData/DodoPizzaTuist-fmlmdqfbrolxgjanbelteljkwvns/Build/Intermediates.noIndex/XCBuildData/cc30cdd1103f0028351f2dccedb15e35-targetGraph.txt
    }
    
    public func activityLogURL() throws -> URL {
        try logFinder.findLatestLogWithLogOptions(logOptions)
    }
}
