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
    
    public typealias ContentsOfDirectory = (_ path: String) throws -> [String]
    let logOptions: LogOptions
    
    public static func pathFinder(
        for project: String,
        derivedDataPath: URL) -> ProjectsFinder {
        let pathFinder = ProjectsFinder(logOptions: .empty)
        return pathFinder
    }
    
    public convenience init(
        logOptions: LogOptions
    ) {
        self.init(logOptions: logOptions,
                  logFinder: LogFinder(derivedDataDir: FileAccess().accessedDerivedDataURL()!))
    }
    
    init(logOptions: LogOptions,
         logFinder: LogFinder
    ) {
        self.logOptions = logOptions
    }
    
    let fileAccess = FileAccess()
    let projectReferenceFactory = ProjectReferenceFactory()
    let defaultDerivedData = DefaultDerivedData()
    
    public func projects() throws -> [ProjectReference] {
        let derivedDataPath = try derivedDataPath()
        let hasAccess = derivedDataPath.startAccessingSecurityScopedResource()
        if !hasAccess {
            print("This directory might not need it, or this URL might not be a security scoped URL, or maybe something's wrong?")
        }
        defer {
            derivedDataPath.stopAccessingSecurityScopedResource()
        }
        
        let derivedDataContents = try derivedDataContents(derivedDataAccessURL: derivedDataPath)
        
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
    
    public func derivedDataContents(
        derivedDataAccessURL: URL
    ) throws -> [String] {
        let contents = try FileManager.default
            .contentsOfDirectory(atPath: derivedDataAccessURL.path)
        return contents
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
