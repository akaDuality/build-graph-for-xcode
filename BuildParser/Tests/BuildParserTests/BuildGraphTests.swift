//
//  BuildGraphTests.swift
//  
//
//  Created by Mikhail Rubanov on 18.10.2021.
//

import XCTest
import CustomDump
import SnapshotTesting

@testable import BuildParser

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

        print(customDump(dependencies))
        assertSnapshot(matching: dependencies, as: .description)
    }
    
    func parse(_ input: String) -> Dependency {
        DependencyParser().parse(input)
    }
    
    func parseFile(_ input: String) -> [Dependency] {
        DependencyParser().parseFile(input)
    }
}

import Foundation

class DependencyParser {
    func parseFile(_ input: String) -> [Dependency] {
        let strings = input.components(separatedBy: "\n")
            .dropFirst() // No need in "Target dependency graph ..."
        
        return deps(Array(strings))
            .map(dependency(from:))
    }
    
    func deps(_ strings: [String]) -> [[String]] {
        var indices = [Int]()
        for (index, string) in strings.enumerated() {
            let startOfDependencies = string.contains(", ")
            if startOfDependencies {
                indices.append(index)
            }
        }
        
        var result = [[String]]()
        for (i, index) in indices.dropLast().enumerated() {
            let nextIndex = indices[i + 1]
            let range = index..<nextIndex
            let depsDescription = strings[range]
            result.append(Array(depsDescription))
        }
        
        result.append(Array(strings[indices.last!...(strings.count - 1)]))
        
        return result
    }
    
    func parse(_ input: String) -> Dependency {
        let strings = input.components(separatedBy: "\n")
            
        return dependency(from: strings)
    }
    
    private func dependency(from strings: [String]) -> Dependency {
        var deps: [Target] = []
        if strings[0].hasSuffix(", depends on:") {
            deps = strings.dropFirst().map(parseTarget(_:))
        }
        
        return Dependency(
            target: parseTarget(strings[0]),
            dependencies: deps)
    }
    
    func parseTarget(_ input: String) -> Target {
        let regex = try! NSRegularExpression(
            pattern: "(\\w*) in (\\w*)")
        
        let matche = regex
            .matches(in: input,
                     options: [],
                     range: input.fullRange)
            .first!
 
        
        return Target(target: matche.xx(at: 1, in: input),
                      project: matche.xx(at: 2, in: input))
    }
}

extension NSTextCheckingResult {
    func xx(at index: Int, in content: String) -> String {
        let rangeInContent = Range(range(at: index),
                                   in: content)!
        
        return String(content[rangeInContent])
    }
}

extension String {
    var fullRange: NSRange {
        return NSRange(location: 0, length: count)
    }
}

struct Dependency: Equatable {
    let target: Target
//    let type: DependencyType
    let dependencies: [Target]
}

struct Target: Equatable {
    let target: String
    let project: String
}

enum DependencyType: Equatable {
//    case explicit
    case implicit
}
