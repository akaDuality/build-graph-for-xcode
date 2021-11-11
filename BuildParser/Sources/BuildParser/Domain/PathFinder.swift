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
    let fileManager = FileManager.default
   
    public func projects() throws -> [String] {
        guard let derivedData = logFinder.getDerivedDataDirWithLogOptions(logOptions) else {
            return []
        }
        
        let contents = try fileManager.contentsOfDirectory(atPath: derivedData.path)
        
        return filter(contents)
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
        try logFinder.findLatestLogWithLogOptions(logOptions)
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
    }
}

