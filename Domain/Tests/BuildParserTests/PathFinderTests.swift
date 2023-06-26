//
//  PathFinderTests.swift
//  
//
//  Created by Mikhail Rubanov on 30.10.2021.
//

import Foundation
import XCTest
import XCLogParser
import CustomDump

@testable import BuildParser

class PathFinderTests: XCTestCase {
    
    var sut: ProjectsFinder!
    
    func test_searchProjects() throws {
        let files = [
            "Manifests-gngpennuzxpepwgywnlojtwalfno",
            "BuildTime-eknojwbtcdfjuxfipboqpabjuzsy",
            "DodoPizzaTuist-fmlmdqfbrolxgjanbelteljkwvns",
            ".DS_Store",
            "ci",
            "SymbolCache.noindex",
            "doner-mobile-ios-frqradomrxpjpuesrfiztrcjbvhf",
            "Unsaved_Xcode_Document-ffgwvkfhkycgbqayujppkkmvzhlp",]

        let projects = sut.filter(files)
        
        XCTAssertNoDifference(projects, [
            "BuildTime-eknojwbtcdfjuxfipboqpabjuzsy",
            "DodoPizzaTuist-fmlmdqfbrolxgjanbelteljkwvns",
            "doner-mobile-ios-frqradomrxpjpuesrfiztrcjbvhf",
            "Unsaved_Xcode_Document-ffgwvkfhkycgbqayujppkkmvzhlp",
        ])
    }
    
    // TODO: Restore
//    func test_searchTargetGraph() throws {
//        let projectDir = URL(string: "/Users/rubanov/Library/Developer/Xcode/DerivedData")!
//
//        let path = try sut.targetGraph(projectDir: projectDir)
//
//        XCTAssertNoDifference(
//            URL(string: "/Users/rubanov/Library/Developer/Xcode/DerivedData/Build/Intermediates.noIndex/XCBuildData/hnthnt-targetGraph.txt"),
//            path)
//    }
    
    override func setUp() {
        super.setUp()
        
//        let url = URL(string: "/Users/rubanov/Library/Developer/Xcode/DerivedData/Build/Intermediates.noIndex/XCBuildData/hnthnt-targetGraph.txt")!
        
        sut = ProjectsFinder(
//            logOptions: logOptions,
//            fileScanner: scannerFake,
//            logFinder: LogFinder(fileManager: FileManager.default)
        )
    }
}

//class LatestFileScannerFake: LatestFileScannerProtocol {
//
//    var files: [URL] = []
//
//    func findLatestForProject(
//        inDir directory: URL,
//        filter: (URL) -> Bool
//    ) throws -> URL {
//        return files.filter(filter).first!
//    }
//}
