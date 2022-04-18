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
//import CryptoSwift

// Thanks to https://pewpewthespells.com/blog/xcode_deriveddata_hashes.html for
// the initial Objective-C implementation.
//public class XcodeHasher {
//
//    enum HashingError: Error {
//        case invalidPartitioning
//    }
//
//    public static func hashString(for path: String) throws -> String {
//        // Initialize a 28 `String` array since we can't initialize empty `Character`s.
//        var result = Array(repeating: "", count: 28)
//
//        // Compute md5 hash of the path
//        let digest = path.bytes.md5()
//
//        // Split 16 bytes into two chunks of 8 bytes each.
//        let partitions = stride(from: 0, to: digest.count, by: 8).map {
//            Array(digest[$0..<Swift.min($0 + 8, digest.count)])
//        }
//        guard let firstHalf = partitions.first else { throw HashingError.invalidPartitioning }
//        guard let secondHalf = partitions.last else { throw HashingError.invalidPartitioning }
//
//        // We would need to reverse the bytes, so we just read them in big endian.
//        #if swift(>=5.0)
//        var startValue = UInt64(bigEndian: Data(firstHalf).withUnsafeBytes { $0.load(as: UInt64.self) })
//        #else
//        var startValue = UInt64(bigEndian: Data(firstHalf).withUnsafeBytes { $0.pointee })
//        #endif
//        for index in stride(from: 13, through: 0, by: -1) {
//            // Take the startValue % 26 to restrict to alphabetic characters and add 'a' scalar value (97).
//            let char = String(UnicodeScalar(Int(startValue % 26) + 97)!)
//            result[index] = char
//            startValue /= 26
//        }
//        // We would need to reverse the bytes, so we just read them in big endian.
//        #if swift(>=5.0)
//        startValue = UInt64(bigEndian: Data(secondHalf).withUnsafeBytes { $0.load(as: UInt64.self) })
//        #else
//        startValue = UInt64(bigEndian: Data(secondHalf).withUnsafeBytes { $0.pointee })
//        #endif
//        for index in stride(from: 27, through: 14, by: -1) {
//            // Take the startValue % 26 to restrict to alphabetic characters and add 'a' scalar value (97).
//            let char = String(UnicodeScalar(Int(startValue % 26) + 97)!)
//            result[index] = char
//            startValue /= 26
//        }
//
//        return result.joined()
//    }
//}

//import XcodeHasher

class DerivedDataByXcodeProjectLocation {
    let buildDirSettingsPrefix = "BUILD_DIR = "
    
    let xcodebuildPath = "/usr/bin/xcodebuild"
    
    let emmptyDirResponseMessage = """
    Error. Couldn't find the derived data directory.
    Please use the --filePath option to specify the path to the xcactivitylog file you want to parse.
    """
    
    public init(fileManager: FileManagerProtocol = FileManager.default) {
        self.fileManager = fileManager
    }
    
    private let fileManager: FileManagerProtocol
    
    /// Gets the full path of the Build/Logs directory for the given project
    /// The directory is inside of the DerivedData directory of the project
    /// It uses the BUILD_DIR directory listed by the command `xcodebuild -showBuildSettings`
    /// - parameter projectPath: The path to the .xcodeproj folder
    /// - returns: The full path to the `Build/Logs` directory
    /// - throws: An error if the derived data directory couldn't be found
    public func logsDirectoryForXcodeProject(projectPath: String) throws -> String {
        let arguments = ["-project", projectPath, "-showBuildSettings"]
        if let result = try executeXcodeBuild(args: arguments) {
            return try parseXcodeBuildDir(result)
        }
        throw LogError.xcodeBuildError(emmptyDirResponseMessage)
    }
    
    /// Gets the latest xcactivitylog file path for the given projectFolder
    /// in the given derived data folder
    /// - parameter projectFolder: The name of the project folder
    /// - parameter derivedDataDir: The path to the derived data folder
    /// - returns: The path to the latest xcactivitylog for the given project folder
    /// - throws an `Error` if no log is found
    public func getLatestLogForProjectFolder(_ projectFolder: String,
                                             inDerivedData derivedDataDir: URL) throws -> URL {
        let logsDirectory = derivedDataDir.appendingPathComponent(projectFolder).appendingPathComponent("Logs/Build")
        return try getLatestLogInDir(logsDirectory, fileManager: fileManager)
    }
    
    /// Gets the available schemes in the given xcworkspace.
    /// Gets the list from the command xcodebuild -workspace -list
    /// - parameter workspace: The path to the .xcworkspace
    /// - throws an Error with the list of the available schemes
    public func logsDirectoryForWorkspace(_ workspace: String) throws {
        let error = """
        If you specify a workspace then you must also specify a scheme with -scheme.
        These are the available schemes in the workspace:
        """
        if let result = try executeXcodeBuild(args: ["-workspace", workspace, "-list"]) {
            guard !result.starts(with: "xcodebuild: error: ") else {
                throw LogError.xcodeBuildError(result.replacingOccurrences(of: "xcodebuild: ", with: ""))
            }
            let schemes = result.split(separator: "\n").filter {
                !$0.contains("Information about") && !$0.contains("Schemes:")
            }.map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }.reduce(error) { "\($0)\n\($1)" }
            throw LogError.xcodeBuildError(schemes)
        }
    }
    
    /// Gets the full path of the Build/Logs directory for the given workspace and scheme
    /// The directory is inside of the DerivedData directory of the project
    /// It uses the BUILD_DIR directory listed by the command `xcodebuild -showBuildSettings`
    /// - parameter workspace: The path to the .xcworkspace folder
    /// - parameter andScheme: The name of the scheme
    /// - returns: The full path to the `Build/Logs` directory
    /// - throws: An error if the derived data directory can't be found.
    public func logsDirectoryForWorkspace(_ workspace: String, andScheme scheme: String) throws -> String {
        let arguments = ["-workspace", workspace, "-scheme", scheme, "-showBuildSettings"]
        if let result = try executeXcodeBuild(args: arguments) {
            return try parseXcodeBuildDir(result)
        }
        throw LogError.xcodeBuildError(emmptyDirResponseMessage)
    }
    
    private func executeXcodeBuild(args: [String]) throws -> String? {
        guard fileManager.isExecutableFile(atPath: xcodebuildPath) else {
            throw LogError.xcodeBuildError("Error: xcodebuild is not installed.")
        }
        let task: Process = Process()
        let pipe: Pipe = Pipe()
        
        task.launchPath = xcodebuildPath
        task.arguments = args
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        
        let handle = pipe.fileHandleForReading
        let data = handle.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
    
    private func parseXcodeBuildDir(_ response: String) throws -> String {
        guard !response.starts(with: "xcodebuild: error: ") else {
            throw LogError.xcodeBuildError(response.replacingOccurrences(of: "xcodebuild: ", with: ""))
        }
        let buildDirSettings = response.split(separator: "\n").filter {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: buildDirSettingsPrefix)
        }
        if let settings = buildDirSettings.first {
            return settings.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: buildDirSettingsPrefix, with: "")
                .replacingOccurrences(of: "Build/Products", with: logsDir)
        }
        throw LogError.xcodeBuildError(emmptyDirResponseMessage)
    }
    
    /// Generates the Derived Data Build Logs Folder name for the given project path
    /// - parameter projectFilePath: A path (relative or absolut) to an .xcworkspace or an .xcodeproj directory
    /// - returns The name of the folder with the same hash Xcode generates.
    /// For instance MyApp-dtpdmwoqyxcbrmauwqvycvmftqah/Logs/Build
    //    public func getProjectFolderWithHash(_ projectFilePath: String) throws -> String {
    //        let path = Path(projectFilePath).absolute()
    //        let projectName = path.lastComponent
    //            .replacingOccurrences(of: ".xcworkspace", with: "")
    //            .replacingOccurrences(of: ".xcodeproj", with: "")
    //        let hash = try XcodeHasher.hashString(for: path.string)
    //        return "\(projectName)-\(hash)"
    //    }
}
