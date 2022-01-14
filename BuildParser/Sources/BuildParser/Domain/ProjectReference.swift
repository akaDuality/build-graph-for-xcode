//
//  ProjectReference.swift
//  
//
//  Created by Mikhail Rubanov on 09.01.2022.
//

import Foundation

public struct ProjectReference: Equatable {
    public init(
        name: String,
        activityLogURL: [URL],
        depsURL: URL?
    ) {
        precondition(activityLogURL.count > 0)
        
        self.currentActivityLogIndex = activityLogURL.count - 1
        self.name = name
        self.activityLogURL = activityLogURL
        self.depsURL = depsURL
    }
    
    public let name: String
    public let activityLogURL: [URL]
    
    public private(set) var currentActivityLogIndex: Int
    public var currentActivityLog: URL {
        activityLogURL[currentActivityLogIndex]
    }
    
    // MARK: - Previous file
    public func canDecreaseFile() -> Bool {
        currentActivityLogIndex > 0
    }
    
    public mutating func selectPreviousFile() {
        precondition(canDecreaseFile())
        
        self.currentActivityLogIndex -= 1
    }
    
    // MARK: - Next file
    public func canIncreaseFile() -> Bool {
        currentActivityLogIndex < activityLogURL.count - 1
    }
    
    public mutating func selectNextFile() {
        precondition(canIncreaseFile())
        
        self.currentActivityLogIndex += 1
    }
    
    public let depsURL: URL?
    
    static func shortName(from fileName: String) -> String {
        fileName.components(separatedBy: "-").dropLast().joined(separator: "-")
    }
}
