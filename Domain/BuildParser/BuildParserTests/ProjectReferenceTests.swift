//
//  ProjectReferenceTests.swift
//  
//
//  Created by Mikhail Rubanov on 09.01.2022.
//

import XCTest
import BuildParser

//class ProjectReferenceTests: XCTestCase {
//    
//    let derivedData = URL(fileURLWithPath: Bundle.module.resourcePath!)
//        .appendingPathComponent("DerivedData")
//    
//    func testConstructorWithProjectFolder() throws {
//        let sut = ProjectReferenceFactory()
//        
//        let project = try XCTUnwrap(
//            sut.projectReference(
//                    accessedDerivedDataURL: derivedData,
//                    fullName: "CodeMetrics-dycvocfpyegeqgbmavxjkihheltm")
//        )
//        
//        XCTAssertEqual(
//            project.name,
//            "CodeMetrics")
//        
//        XCTAssertEqual(
//           project.activityLogURL,
//           [derivedData.appendingPathComponent("CodeMetrics-dycvocfpyegeqgbmavxjkihheltm/Logs/Build/1CEFFBA1-72C4-458C-966E-91BB42B2C222.xcactivitylog"),
//            derivedData.appendingPathComponent("CodeMetrics-dycvocfpyegeqgbmavxjkihheltm/Logs/Build/0F14C80C-80E0-4798-B970-5956D7A6D8BC.xcactivitylog")
//           ])
//        
//        XCTAssertEqual(
//            project.depsURL,
//            derivedData.appendingPathComponent("CodeMetrics-dycvocfpyegeqgbmavxjkihheltm/Build/Intermediates.noindex/XCBuildData/6dc3c5f17f0bf003046e94e4e0f7185b-targetGraph.txt")
//            )
//    }
//    
//    // TODO: Test failable initializer
//    
//    func testConstructorWithDirectPath() throws {
//        let sut = ProjectReferenceFactory()
//        
//        let project = try XCTUnwrap(
//            sut.projectReference(
//                activityLogURL:
//                    derivedData.appendingPathComponent("CodeMetrics-dycvocfpyegeqgbmavxjkihheltm/Logs/Build/1CEFFBA1-72C4-458C-966E-91BB42B2C222.xcactivitylog"),
//                accessedDerivedDataURL: derivedData)
//        )
//
//        XCTAssertEqual(
//            project.name,
//            "CodeMetrics")
//
//        XCTAssertEqual(
//            project.activityLogURL,
//            
//            [derivedData.appendingPathComponent("CodeMetrics-dycvocfpyegeqgbmavxjkihheltm/Logs/Build/1CEFFBA1-72C4-458C-966E-91BB42B2C222.xcactivitylog"),
//            ])
//        // TODO: should I find all files?
//
//        XCTAssertEqual(
//            project.depsURL,
//            derivedData.appendingPathComponent("CodeMetrics-dycvocfpyegeqgbmavxjkihheltm/Build/Intermediates.noindex/XCBuildData/6dc3c5f17f0bf003046e94e4e0f7185b-targetGraph.txt")
//        )
//    }
//}

import XCLogParser
class FileAccessMock: FileAccessProtocol {
    func pathFinder(for project: String, derivedDataPath: URL) -> ProjectsFinder {
        ProjectsFinder(
//            logFinder: LogFinder(fileManager: FileManagerMock())
        )
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
