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
    
    var sut: PathFinder!
    
    func test_searchProjects() throws {
        let files = [
            "Manifests-gngpennuzxpepwgywnlojtwalfno",
            "BuildTime-eknojwbtcdfjuxfipboqpabjuzsy",
            "Manifests-hbhyuhctvlhbkqaezwtitstvcnop",
            "DodoPizzaTuist-fmlmdqfbrolxgjanbelteljkwvns",
            ".DS_Store",
            "ci",
            "PaymentSDK-epdajnbafxscmpcmnytzqodeoued",
            "DodoPizza-glhhbebrgwnhsvfgddjdmypkcwlk",
            "Manifests-emwhhqzhkhppiqdbwoxhtrkpljnb",
            "Manifests-cfgulhwttugwzmdhzcyzxbooucnb",
            "Manifests-bznommulvbditudpqsicedztbvsl",
            "SymbolCache.noindex",
            "Drinkit-bueujozjfjpentfexjizqlxlclea",
            "XCLogParser-fyvvequtkujqnyastwetyijtldoe",
            "Manifests-afqaygpatuxnfzdusyftbnvqtrzp",
            "doner-mobile-ios-frqradomrxpjpuesrfiztrcjbvhf",
            "Manifests-djdpzgbnvlfdowgkoblzwwvhdaqa",
            "CodeMetrics-aegjnninizgadzcfxjaecrwuhtfu",
            "Unsaved_Xcode_Document-ffgwvkfhkycgbqayujppkkmvzhlp",
            "BuildParser-ehmtqriycvpelfczhmlcgerqvbid",
            "Manifests-daewhugcogodvmdbuzharopkksjt",
            "ModuleCache.noindex",
            "Manifests-bdrbthouepmjjaghpwddovfawfmv",
            "MobileBackend-cvrhpzhjkorouceksilhvzguxdaa",
            "BuildGant-fjrcufjeignxpbbooxtkkpdrtiaa",
            "DemoAppTemplateWorkspace-gcfswczfpauaeuhknnmquphalhnp",
            "Prep_Station-cqsgezhuszefskevdmvmxurzyrok",
            "PaymentSDK-gcjsauiwilsvsndrwbjoayzimvvk",
            "AccessibilityTask-bescjmvjnldqssfklrexxvsfbkiz",
            "Manifests-dpvwxxklzfvsjjgaowpmqxfjurte",
            "Manifests-dyddubhdmzxtgvdmloxcptpndcqe",
            "DemoAppTemplate-doprfuhozangbwersngwzahibsce",]

        let projects = sut.filter(files)
        
        XCTAssertNoDifference(projects, [
            "BuildTime",
            "DodoPizzaTuist",
            "PaymentSDK",
            "DodoPizza",
            "Drinkit",
            "XCLogParser",
            "doner-mobile-ios",
            "CodeMetrics",
            "Unsaved_Xcode_Document",
            "BuildParser",
            "MobileBackend",
            "BuildGant",
            "DemoAppTemplateWorkspace",
            "Prep_Station",
            "PaymentSDK",
            "AccessibilityTask",
            "DemoAppTemplate",
        ])
    }
    
    func test_searchTargetGraph() throws {
        let projectDir = URL(string: "/Users/rubanov/Library/Developer/Xcode/DerivedData")!
        
        let path = try sut.targetGraph(projectDir: projectDir)
        
        XCTAssertNoDifference(
            URL(string: "/Users/rubanov/Library/Developer/Xcode/DerivedData/Build/Intermediates.noIndex/XCBuildData/hnthnt-targetGraph.txt"),
            path)
    }
    
    override func setUp() {
        super.setUp()
        
        scannerFake = LatestFileScannerFake()
        let url = URL(string: "/Users/rubanov/Library/Developer/Xcode/DerivedData/Build/Intermediates.noIndex/XCBuildData/hnthnt-targetGraph.txt")!
        scannerFake.files = [url]
        
        sut = PathFinder(
            logOptions: logOptions,
            fileScanner: scannerFake
        )
    }
    
    var scannerFake: LatestFileScannerFake!
}

class LatestFileScannerFake: LatestFileScannerProtocol {
    
    var files: [URL] = []
    
    func findLatestForProject(
        inDir directory: URL,
        filter: (URL) -> Bool
    ) throws -> URL {
        return files.filter(filter).first!
    }
}
