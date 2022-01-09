//
//  ProjectReferenceTests.swift
//  
//
//  Created by Mikhail Rubanov on 09.01.2022.
//

import XCTest
import BuildParser

class ProjectReferenceTests: XCTestCase {
    
    let derivedData = URL(fileURLWithPath: "/Users/rubanov/Library/Developer/Xcode/DerivedData")

    func testConstructorWithProjectFolder() throws {
        let project = ProjectReference(
            url: derivedData,
            fullName: "CodeMetrics-aegjnninizgadzcfxjaecrwuhtfu",
            fileAccess: FileAccessMock())
        
        XCTAssertEqual(
            project?.name,
            "CodeMetrics")
        
        XCTAssertEqual(
            project?.activityLogURL,
            URL(fileURLWithPath: "/Users/rubanov/Library/Developer/Xcode/DerivedData/CodeMetrics-aegjnninizgadzcfxjaecrwuhtfu/Logs/Build/66C2880B-2FCD-4258-8E15-E3FC44E6150F.xcactivitylog"))
        
        XCTAssertEqual(
            project?.depsURL,
            URL(fileURLWithPath: "/Users/rubanov/Library/Developer/Xcode/DerivedData/CodeMetrics-aegjnninizgadzcfxjaecrwuhtfu/Build/Intermediates.noindex/XCBuildData/689fa20537462d0bb083fe9757e30717-targetGraph.txt"))
    }
    
    // TODO: Test failable initializer
    
    func testConstructorWithDirectPath() {
        let project = ProjectReference(
            path: "/Users/rubanov/Library/Developer/Xcode/DerivedData/CodeMetrics-aegjnninizgadzcfxjaecrwuhtfu/Logs/Build/66C2880B-2FCD-4258-8E15-E3FC44E6150F.xcactivitylog",
            fileAccess: FileAccessMock())
        
        XCTAssertEqual(
            project.name,
            "CodeMetrics")
        
        XCTAssertEqual(
            project.activityLogURL,
            URL(fileURLWithPath: "/Users/rubanov/Library/Developer/Xcode/DerivedData/CodeMetrics-aegjnninizgadzcfxjaecrwuhtfu/Logs/Build/66C2880B-2FCD-4258-8E15-E3FC44E6150F.xcactivitylog"))
        
        XCTAssertEqual(
            project.depsURL,
            URL(fileURLWithPath: "/Users/rubanov/Library/Developer/Xcode/DerivedData/CodeMetrics-aegjnninizgadzcfxjaecrwuhtfu/Build/Intermediates.noindex/XCBuildData/689fa20537462d0bb083fe9757e30717-targetGraph.txt")
        )
    }
}

import XCLogParser
class FileAccessMock: FileAccessProtocol {
    func pathFinder(for project: String, derivedDataPath: URL) -> PathFinder {
        PathFinder(
            logOptions: .empty,
            logFinder: LogFinder(fileManager: FileManagerMock()))
    }
    func accessedDerivedDataURL() -> URL? {
        return URL(fileURLWithPath: "/Users/rubanov/Library/Developer/Xcode/DerivedData/")
    }
}

class FileManagerMock: FileManagerProtocol {
    func fileExists(atPath: String) -> Bool {
        false
    }
    
    func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options mask: FileManager.DirectoryEnumerationOptions
    ) throws -> [URL] {
        []
    }
    
    func isExecutableFile(atPath path: String) -> Bool {
        false
    }
}
