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
        let url = Bundle.module.url(forResource: "targetGraph", withExtension: "txt")!
        let string = try String(contentsOf: url, encoding: .utf8)
        let dependencies = parseFile(string)

        assertSnapshot(matching: dependencies, as: .description)
    }
    
    func parse(_ input: String) -> Dependency {
        DependencyParser().parse(input)
    }
    
    func parseFile(_ input: String) -> [Dependency] {
        DependencyParser().parseFile(input)
    }
}
