//
//  ProjectReference.swift
//  
//
//  Created by Mikhail Rubanov on 09.01.2022.
//

import Foundation

public struct ProjectReference: Equatable {
    public let name: String
    public let activityLogURL: URL
    public let depsURL: URL?
    
    public init(path: String,
                fileAccess: FileAccessProtocol = FileAccess()) {
        let pathURL = URL(fileURLWithPath: path)
        self.activityLogURL = pathURL
        
        let folderWithName = pathURL.pathComponents[pathURL.pathComponents.count - 4]
        self.name = Self.shortName(from: folderWithName)
        
        let pathFinder = PathFinder.pathFinder(
            for: self.name,
               derivedDataPath: fileAccess.accessedDerivedDataURL()!)
        
        self.depsURL = try? pathFinder.buildGraphURL()
    }
    
    public init?(
        url: URL,
        fullName: String,
        fileAccess: FileAccessProtocol = FileAccess()
    ) {
        let shortName = Self.shortName(from: fullName)
        self.name = shortName
        
        let pathFinder = PathFinder.pathFinder(
            for: shortName,
               derivedDataPath: fileAccess.accessedDerivedDataURL()!)
        
        do {
            self.activityLogURL = try pathFinder.activityLogURL()
            self.depsURL = try? pathFinder.buildGraphURL()
        } catch {
            print("skip \(self.name), can't find .activityLog with build information")
            return nil
        }
    }
    
    static func shortName(from fileName: String) -> String {
        fileName.components(separatedBy: "-").dropLast().joined(separator: "-")
    }
}
