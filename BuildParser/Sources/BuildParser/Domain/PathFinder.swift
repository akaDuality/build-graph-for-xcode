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
    let contentsOfDirectory: ContentsOfDirectory
    
    public init(
        logOptions: LogOptions,
        contentsOfDirectory: @escaping ContentsOfDirectory
        = FileManager.default.contentsOfDirectory) {
            self.logOptions = logOptions
            self.contentsOfDirectory = contentsOfDirectory
    }
    
    let logFinder = LogFinder()
    
    public func buildGraphURL() throws -> URL {
        let projectDir = try logFinder.getProjectDirWithLogOptions(logOptions)
        return try targetGraph(projectDir: projectDir)
    }
    
    func targetGraph(projectDir: URL) throws -> URL {
        let intemediates = projectDir
            .appendingPathComponent("Build")
            .appendingPathComponent("Intermediates.noIndex")
            .appendingPathComponent("XCBuildData")
       
        
        for filePath in try contentsOfDirectory(intemediates.path) {
            // TODO: Select with proper ID
            if filePath.hasSuffix("-targetGraph.txt") {
                return intemediates.appendingPathComponent(filePath)
            }
        }
        
        throw Error.graphNotFound
    }
    
    public func activityLogURL() throws -> URL {
        try logFinder.findLatestLogWithLogOptions(logOptions)
    }
    
    enum Error: Swift.Error {
        case graphNotFound
    }
}


