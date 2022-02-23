//
//  PathFinder.swift
//  
//
//  Created by Mikhail Rubanov on 25.10.2021.
//

import Foundation
import XCLogParser
import Foundation

public class ProjectsFinder {
    
    public init() {}
    
    let fileAccess = FileAccess()
    let projectReferenceFactory = ProjectReferenceFactory()
    let defaultDerivedData = DefaultDerivedData()
    
    public func projects(derivedDataPath: URL) throws -> [ProjectReference] {
        let hasAccess = derivedDataPath.startAccessingSecurityScopedResource()
        if !hasAccess {
            print("This directory might not need it, or this URL might not be a security scoped URL, or maybe something's wrong?")
        }
        defer {
            derivedDataPath.stopAccessingSecurityScopedResource()
        }
        
        let derivedDataContents = try FileManager.default
            .contentsOfDirectory(atPath: derivedDataPath.path)
        
        let result = filter(derivedDataContents)
            .compactMap {
                projectReferenceFactory
                    .projectReference(
                        accessedDerivedDataURL: derivedDataPath,
                        fullName: $0)
            }
        
        return result
    }
    
    public func derivedDataPath() throws -> URL {
        guard let derivedDataURL = defaultDerivedData.getDerivedDataDir() else {
            throw Error.noDerivedData
        }
        
        // TODO: Handle file deprecation
        let derivedDataAccessURL = try fileAccess.promptForWorkingDirectoryPermission(directoryURL: derivedDataURL)!
        return derivedDataAccessURL
    }
    
    func filter(_ names: [String]) -> [String] {
        return names
            .filter { $0.contains("-") }
            .filter { !$0.contains("Manifests") } // TODO: Is it Tuist? Remove from prod
    }
    
    enum Error: Swift.Error {
        case noDerivedData
        case cantAccessResourceInScope
    }
}
