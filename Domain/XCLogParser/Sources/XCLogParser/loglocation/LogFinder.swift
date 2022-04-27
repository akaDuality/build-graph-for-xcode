// Copyright (c) 2019 Spotify AB.
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation
//import PathKit

public protocol FileManagerProtocol {
    func fileExists(atPath: String) -> Bool
    
    func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options mask: FileManager.DirectoryEnumerationOptions
    ) throws -> [URL]
    
    func isExecutableFile(atPath path: String) -> Bool
}

extension FileManager: FileManagerProtocol {}

let logsDir = "/Logs/Build/"

/// Helper methods to locate Xcode's Log directory and its content
public struct LogFinder {

    public init(projectDir: URL, fileManager: FileManagerProtocol = FileManager.default) {
        self.projectDir = projectDir
        self.fileManager = fileManager
    }
    
    private let fileManager: FileManagerProtocol
    private let projectDir: URL

    public func latestActivityLog() throws -> URL {
        // get project dir
        let projectDir = try getLogsDirectory()

        // get latestLog

        return try getLatestLogInDir(projectDir, fileManager: fileManager)
    }
    
    public func activityLogs() throws -> [URL] {
        // get project dir
        let projectDir = try getLogsDirectory()
        
        // get latestLog
        
        return try getLogsInDir(projectDir, fileManager: fileManager)
    }
    
    private func getLogsDirectory() throws -> URL {
        try getProjectDir()
            .appendingPathComponent(logsDir)
    }

    public func getProjectDir() throws -> URL {
        let path = projectDir.appendingPathComponent(logsDir).path
        if fileManager.fileExists(
            atPath: path) {
            return projectDir
        }

        throw LogError.noLogFound(dir: projectDir.path)
    }
    
    public func buildGraphURL() throws -> URL {
        let projectDir = try getProjectDir()
        return try targetGraph(projectDir: projectDir)
    }
    
    func targetGraph(projectDir: URL) throws -> URL {
        let intemediates = projectDir
            .appendingPathComponent("Build")
            .appendingPathComponent("Intermediates.noIndex")
            .appendingPathComponent("XCBuildData")
        
        let graph = try LatestFileScanner().findLatestForProject(inDir: intemediates, filter: { url in
            url.path.hasSuffix("-targetGraph.txt")
        })
        return graph
    }
}

class LatestFileScanner {
    
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
                
                guard let lhDate = lhv.creationDate,
                      let rhDate = rhv.creationDate
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

/// Returns the latest xcactivitylog file path in the given directory
/// - parameter dir: The full path for the directory
/// - returns: The path for the latest xcactivitylog file in it.
/// - throws: An `Error` if the directory doesn't exist or if there are no xcactivitylog files in it.
public func getLatestLogInDir(_ dir: URL, fileManager: FileManagerProtocol) throws -> URL {
    let sorted = try getLogsInDir(dir, fileManager: fileManager)
    
    guard let logPath = sorted.last else {
        throw LogError.noLogFound(dir: dir.path)
    }
    
    return logPath
}

public func getLogsInDir(_ dir: URL, fileManager: FileManagerProtocol) throws -> [URL] {
    let files = try fileManager.contentsOfDirectory(at: dir,
                                                    includingPropertiesForKeys: [.creationDateKey],
                                                    options: .skipsHiddenFiles)
    let sorted = try files.filter { $0.path.hasSuffix(".xcactivitylog") }.sorted {
        let lhv = try $0.resourceValues(forKeys: [.creationDateKey])
        let rhv = try $1.resourceValues(forKeys: [.creationDateKey])
        guard let lhDate = lhv.creationDate, let rhDate = rhv.creationDate else {
            return false
        }
        return lhDate.compare(rhDate) == .orderedDescending
    }

    return sorted
}
