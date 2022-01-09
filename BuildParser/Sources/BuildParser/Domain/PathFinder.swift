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
    
    public typealias ContentsOfDirectory = (_ path: String) throws -> [String]
    let logOptions: LogOptions
    let fileScanner: LatestFileScannerProtocol
    
    public static func pathFinder(
        for project: String,
        derivedDataPath: URL,
        logFinder: LogFinder = LogFinder()) -> PathFinder {
        let options = LogOptions(
            projectName: project,
            xcworkspacePath: "",
            xcodeprojPath: "",
            derivedDataPath: derivedDataPath,
            logManifestPath: "")
        let pathFinder = PathFinder(logOptions: options,
                                    logFinder: logFinder)
        return pathFinder
    }
    
    public convenience init(
        logOptions: LogOptions,
        logFinder: LogFinder = LogFinder()
    ) {
        self.init(logOptions: logOptions,
                  fileScanner: LatestFileScanner(),
                  logFinder: logFinder)
    }
    
    init(logOptions: LogOptions,
         fileScanner: LatestFileScannerProtocol,
         logFinder: LogFinder
    ) {
        self.logOptions = logOptions
        self.fileScanner = fileScanner
        self.logFinder = logFinder
    }
    
    let logFinder: LogFinder
    let fileAccess = FileAccess()
    let projectReferenceFactory = ProjectReferenceFactory()
    
    public func projects() throws -> [ProjectReference] {
        let derivedDataPath = try derivedDataPath(logOptions)
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
    
    public func derivedDataPath(_ logOptions: LogOptions) throws -> URL {
        guard let derivedDataURL = logFinder.getDerivedDataDirWithLogOptions(logOptions) else {
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
    
    public func buildGraphURL() throws -> URL {
        let projectDir = try logFinder.getProjectDirWithLogOptions(logOptions)
        return try targetGraph(projectDir: projectDir)
    }
    
    func targetGraph(projectDir: URL) throws -> URL {
        let intemediates = projectDir
            .appendingPathComponent("Build")
            .appendingPathComponent("Intermediates.noIndex")
            .appendingPathComponent("XCBuildData")
        
        let graph = try fileScanner.findLatestForProject(inDir: intemediates, filter: { url in
            url.path.hasSuffix("-targetGraph.txt")
        })
        return graph
    }
    
    public func activityLogURL() throws -> URL {
        // TODO: Handle optional
//        let derivedDataURL = logFinder.getDerivedDataDirWithLogOptions(logOptions)!
        
        return try logFinder.findLatestLogWithLogOptions(logOptions)
    }
    
    enum Error: Swift.Error {
        case noDerivedData
        case cantAccessResourceInScope
    }
}
