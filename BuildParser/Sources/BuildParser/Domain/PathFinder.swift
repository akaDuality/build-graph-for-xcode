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
    
    public convenience init(
        logOptions: LogOptions)
    {
        self.init(logOptions: logOptions,
                  fileScanner: LatestFileScanner())
    }
    
    init(logOptions: LogOptions,
         fileScanner: LatestFileScannerProtocol) {
            self.logOptions = logOptions
            self.fileScanner = fileScanner
    }
    
    let logFinder = LogFinder()
    let fileAccess = FileAccess()
    
    public func projects() throws -> [String] {
        let derivedDataContents = try derivedDataContents(logOptions)
        return filter(derivedDataContents)
    }
    
    public func derivedDataContents(
        _ logOptions: LogOptions
    ) throws -> [String] {
        guard let derivedDataURL = logFinder.getDerivedDataDirWithLogOptions(logOptions) else {
            return []
        }
        
        // TODO: Handle file deprecation
        let derivedDataAccessURL = try fileAccess.promptForWorkingDirectoryPermission(directoryURL: derivedDataURL)!
        
        let hasAccess = derivedDataAccessURL.startAccessingSecurityScopedResource()
        if !hasAccess {
            print("This directory might not need it, or this URL might not be a security scoped URL, or maybe something's wrong?")
        }
        defer {
            derivedDataAccessURL.stopAccessingSecurityScopedResource()
        }
        
        let contents = try FileManager.default
            .contentsOfDirectory(atPath: derivedDataAccessURL.path)
        return contents
    }
    
    func filter(_ urls: [String]) -> [String] {
        urls
            .filter { $0.contains("-") }
            .filter { !$0.contains("Manifests") } // TODO: Is it Tuist? Remove from prod
            .map { $0.components(separatedBy: "-").dropLast().joined(separator: "-") }
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
        let derivedDataURL = logFinder.getDerivedDataDirWithLogOptions(logOptions)!
        
        return try logFinder.findLatestLogWithLogOptions(logOptions)
    }
    
    enum Error: Swift.Error {
        case cantAccessResourceInScope
    }
}

protocol LatestFileScannerProtocol {
    func findLatestForProject(inDir directory: URL,
                              filter: (URL) -> Bool) throws -> URL
}

class LatestFileScanner: LatestFileScannerProtocol {
    
    let fileManager = FileManager.default
    
    func findLatestForProject(
        inDir directory: URL,
        filter: (URL) -> Bool
    ) throws -> URL {
        let files = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles)
        
        let sorted = try files.filter(filter)
            .sorted {
                let lhv = try $0.resourceValues(forKeys: [.contentModificationDateKey])
                let rhv = try $1.resourceValues(forKeys: [.contentModificationDateKey])
                
                guard let lhDate = lhv.contentModificationDate,
                      let rhDate = rhv.contentModificationDate
                else {
                    return false
                }
                
                return lhDate.compare(rhDate) == .orderedDescending
            }
        guard let match = sorted.first else {
            throw Error.graphNotFound
        }
        return match
    }
    
    enum Error: Swift.Error {
        case graphNotFound
        case cantAccessResourceInScope
    }
}

