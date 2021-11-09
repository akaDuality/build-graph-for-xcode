//
//  BuildGraphTests.swift
//  
//
//  Created by Mikhail Rubanov on 18.10.2021.
//

import XCTest
import CustomDump
import Interface
import SnapshotTesting

@testable import GraphParser

// Use https://regex101.com to validate regex
// HCaptcha-HCaptcha in HCaptcha, no dependencies
// Crypto in Crypto, no dependencies
// Crypto in Crypto (explicit)
class BuildGraphTests: XCTestCase {
    
    let Crypto = Target(target: "Crypto",
                        project: "Crypto")
    
    let Acquirers = Target(target: "Acquirers",
                           project: "Acquirers")
    
    func test_noDependency_Crypto() {
        let dependency = parse("Crypto in Crypto, no dependencies")
        
        XCTAssertNoDifference(
            dependency,
            Dependency(target: Crypto,
                       dependencies: []))
    }
    
    func test_noDependency_Autocomplete() {
        
        let dependency = parse("Acquirers in Acquirers, no dependencies")
        
        XCTAssertNoDifference(
            dependency,
            Dependency(target: Acquirers,
                       dependencies: []))
    }
    
    func test_1Dependency() throws {
        let dependency = parse(
"""
Acquirers in Acquirers, depends on:
Crypto in Crypto (explicit)
"""
        )
        
        XCTAssertNoDifference(
            dependency,
            Dependency(target: Acquirers,
                       dependencies: [Crypto]))
    }
    
    func test_3Dependency() throws {
        let DCommon = Target(target: "DCommon", project: "DCommon")
        let NCallback = Target(target: "NCallback", project: "NCallback")
        let NQueue = Target(target: "NQueue", project: "NQueue")
        
        let dependency = parse(
"""
DCommon in DCommon, depends on:
NCallback in NCallback (explicit)
NQueue in NQueue (explicit)
"""
        )
        
        XCTAssertNoDifference(
            dependency,
            Dependency(target: DCommon,
                       dependencies: [NCallback, NQueue]))
    }
    func test_flags() throws {
        let MindBoxNotification = Target(target: "MindBoxNotification", project: "DodoPizza")
        let nanopb = Target(target: "nanopb", project: "nanopb")
        
        let dependency = parse(
"""
MindBoxNotification in DodoPizza, depends on:
nanopb in nanopb (implicit dependency via options '-framework nanopb' in build setting 'OTHER_LDFLAGS')
"""
        )
        
        XCTAssertNoDifference(
            dependency,
            Dependency(target: MindBoxNotification,
                       dependencies: [nanopb]))
    }
    
    func test_circleDependency() throws {
        let HCaptcha_HCaptcha = Target(target: "HCaptcha-HCaptcha", project: "HCaptcha")
        let HCaptcha = Target(target: "HCaptcha", project: "HCaptcha")
        
        let dependencies = parseFile(
"""
Target dependency graph (2 targets)
HCaptcha-HCaptcha in HCaptcha, no dependencies
HCaptcha in HCaptcha, depends on:
HCaptcha-HCaptcha in HCaptcha (explicit)
"""
        )
        
        XCTAssertNoDifference(
            dependencies,
            [
                Dependency(target: HCaptcha_HCaptcha,
                           dependencies: []),
                Dependency(target: HCaptcha,
                           dependencies: [HCaptcha_HCaptcha])
            ])
    }
    
    func test_file() {
        let dependencies = parseFile(
"""
Target dependency graph (92 targets)
Crypto in Crypto, no dependencies
Acquirers in Acquirers, depends on:
Crypto in Crypto (explicit)
"""
        )
        
        XCTAssertNoDifference(
            dependencies,
            [
                Dependency(target: Crypto,
                           dependencies: []),
                Dependency(target: Acquirers,
                           dependencies: [Crypto]),
            ])
    }
    
    func test_wholeFile() throws {
        throw XCTSkip("Periods calculates from subtask")
        let url = Bundle.module.url(forResource: "targetGraph", withExtension: "txt")!
        let string = try String(contentsOf: url, encoding: .utf8)
        let dependencies = parseFile(string)

        assertSnapshot(matching: dependencies,
                       as: .description
//                       , record: true
        )
    }
    
    func parse(_ input: String) -> Dependency {
        DependencyParser().parse(input)
    }
    
    func parseFile(_ input: String) -> [Dependency] {
        DependencyParser().parseFile(input)
    }
}
