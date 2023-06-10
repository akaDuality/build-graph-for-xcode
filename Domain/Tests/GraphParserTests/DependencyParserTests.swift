//
//  BuildGraphTests.swift
//  
//
//  Created by Mikhail Rubanov on 18.10.2021.
//

import XCTest
import CustomDump
import SnapshotTesting

@testable import GraphParser

// Use https://regex101.com to validate regex
// HCaptcha-HCaptcha in HCaptcha, no dependencies
// Crypto in Crypto, no dependencies
// Crypto in Crypto (explicit)
class BuildGraphTests: XCTestCase {
    
    let Crypto = Target(target: "Crypto",
                        project: "Crypto")
    
    let CryptoSwift = Target(target: "CryptoSwift",
                             project: "CryptoSwift")
    
    let Acquirers = Target(target: "Acquirers",
                           project: "Acquirers")
    
    let libPhoneNumber_iOS = Target(target: "libPhoneNumber-iOS",
                                    project: "libPhoneNumber-iOS")
    
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
    
    func test_dashFirstDependency() throws {
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
    
    func test_dashBothDependency() throws {
        let dependency = parse(
"""
libPhoneNumber-iOS in libPhoneNumber-iOS, no dependencies
"""
        )
        
        XCTAssertNoDifference(
            dependency,
            Dependency(target: libPhoneNumber_iOS,
                       dependencies: []))
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
        let url = Bundle(for: DependencyParser.self)
            .url(forResource: "targetGraph",
                 withExtension: "txt")!
        let string = try String(contentsOf: url, encoding: .utf8)
        let dependencies = parseFile(string)

        assertSnapshot(matching: dependencies,
                       as: .description
//                       , record: true
        )
    }
    
    func test_recursiveDependency() {
        let dependencies = parseFile(
"""
//Target dependency graph (14 targets)
//CryptoSwift in CryptoSwift, no dependencies
//CryptoSwift in CryptoSwift, depends on:
//CryptoSwift in CryptoSwift (explicit)
"""
        )
        
        XCTAssertNoDifference(
            dependencies,
            [
                Dependency(target: CryptoSwift,
                           dependencies: []),
            ])
    }
    
    func parse(_ input: String) -> Dependency {
        DependencyParser().parse(input)!
    }
    
    func parseFile(_ input: String) -> [Dependency] {
        DependencyParser().parseFile(input)
    }
    
    // MARK: Xcode 15
    
    func test_xcode15_part() {
        let depedencies = DependencyParser15().parseFile("""
Target dependency graph (1 targets)
Target \'App\' in project \'App\'
➜ Explicit dependency on target \'App\' in project \'App\'
➜ Explicit dependency on target \'App_App\' in project \'App\'
➜ Explicit dependency on target \'UI\' in project \'UI\'
""")
        
        XCTAssertNoDifference(depedencies, [
            Dependency(target: Target(target: "App", project: "App"),
                       dependencies: [
                        Target(target: "App", project: "App"),
                        Target(target: "App_App", project: "App"),
                        Target(target: "UI", project: "UI"),
                       ])
            ])
    }
}

let xcode15 = """
Target dependency graph (19 targets)
Target \'BuildGraphDebug\' in project \'BuildGraphDebug\'
➜ Explicit dependency on target \'App\' in project \'App\'
Target \'App\' in project \'App\'
➜ Explicit dependency on target \'App\' in project \'App\'
➜ Explicit dependency on target \'App_App\' in project \'App\'
➜ Explicit dependency on target \'UI\' in project \'UI\'
Target \'App\' in project \'App\'
➜ Explicit dependency on target \'App_App\' in project \'App\'
➜ Explicit dependency on target \'UI\' in project \'UI\'
Target \'UI\' in project \'UI\'
➜ Explicit dependency on target \'Details\' in project \'UI\'
➜ Explicit dependency on target \'Filters\' in project \'UI\'
➜ Explicit dependency on target \'Projects\' in project \'UI\'
➜ Explicit dependency on target \'UI_Details\' in project \'UI\'
➜ Explicit dependency on target \'UI_Filters\' in project \'UI\'
➜ Explicit dependency on target \'UI_Projects\' in project \'UI\'
➜ Explicit dependency on target \'Domain\' in project \'Domain\'
➜ Explicit dependency on target \'XCLogParser\' in project \'XCLogParser\'
Target \'Projects\' in project \'UI\'
➜ Explicit dependency on target \'UI_Projects\' in project \'UI\'
➜ Explicit dependency on target \'Domain\' in project \'Domain\'
Target \'UI_Projects\' in project \'UI\' (no dependencies)
Target \'Filters\' in project \'UI\'
➜ Explicit dependency on target \'UI_Filters\' in project \'UI\'
➜ Explicit dependency on target \'Domain\' in project \'Domain\'
Target \'UI_Filters\' in project \'UI\' (no dependencies)
Target \'Details\' in project \'UI\'
➜ Explicit dependency on target \'UI_Details\' in project \'UI\'
➜ Explicit dependency on target \'Domain\' in project \'Domain\'
➜ Explicit dependency on target \'XCLogParser\' in project \'XCLogParser\'
Target \'Domain\' in project \'Domain\'
➜ Explicit dependency on target \'BuildParser\' in project \'Domain\'
➜ Explicit dependency on target \'GraphParser\' in project \'Domain\'
➜ Explicit dependency on target \'XCLogParser\' in project \'XCLogParser\'\nTarget \'BuildParser\' in project \'Domain\'
➜ Explicit dependency on target \'GraphParser\' in project \'Domain\'
➜ Explicit dependency on target \'XCLogParser\' in project \'XCLogParser\'
Target \'XCLogParser\' in project \'XCLogParser\'
➜ Explicit dependency on target \'XCLogParser\' in project \'XCLogParser\'
➜ Explicit dependency on target \'Gzip\' in project \'Gzip\'
Target \'XCLogParser\' in project \'XCLogParser\'
➜ Explicit dependency on target \'Gzip\' in project \'Gzip\'
Target \'Gzip\' in project \'Gzip\'
➜ Explicit dependency on target \'Gzip\' in project \'Gzip\'
➜ Explicit dependency on target \'system-zlib\' in project \'Gzip\'
Target \'Gzip\' in project \'Gzip\'
➜ Explicit dependency on target \'system-zlib\' in project \'Gzip\'
Target \'system-zlib\' in project \'Gzip\' (no dependencies)
Target \'GraphParser\' in project \'Domain\' (no dependencies)
Target \'UI_Details\' in project \'UI\' (no dependencies)
Target \'App_App\' in project \'App\' (no dependencies)
"""

let xcode14 = """
Target dependency graph (19 targets)
App_App in App, no dependencies
UI_Details in UI, no dependencies
GraphParser in Domain, no dependencies
system-zlib in Gzip, no dependencies
Gzip in Gzip, depends on:
system-zlib in Gzip (explicit)
Gzip in Gzip, depends on:
Gzip in Gzip (explicit)
system-zlib in Gzip (explicit)
XCLogParser in XCLogParser, depends on:
Gzip in Gzip (explicit)
XCLogParser in XCLogParser, depends on:
XCLogParser in XCLogParser (explicit)
Gzip in Gzip (explicit)
BuildParser in Domain, depends on:
GraphParser in Domain (explicit)
XCLogParser in XCLogParser (explicit)
Domain in Domain, depends on:
BuildParser in Domain (explicit)
GraphParser in Domain (explicit)
XCLogParser in XCLogParser (explicit)
Details in UI, depends on:
UI_Details in UI (explicit)
Domain in Domain (explicit)
XCLogParser in XCLogParser (explicit)
UI_Filters in UI, no dependencies
Filters in UI, depends on:
UI_Filters in UI (explicit)
Domain in Domain (explicit)
UI_Projects in UI, no dependencies
Projects in UI, depends on:
UI_Projects in UI (explicit)
Domain in Domain (explicit)
UI in UI, depends on:
Details in UI (explicit)
Filters in UI (explicit)
Projects in UI (explicit)
UI_Details in UI (explicit)
UI_Filters in UI (explicit)
UI_Projects in UI (explicit)
Domain in Domain (explicit)
XCLogParser in XCLogParser (explicit)
App in App, depends on:
App_App in App (explicit)
UI in UI (explicit)
App in App, depends on:
App in App (explicit)
App_App in App (explicit)
UI in UI (explicit)
BuildGraphDebug in BuildGraphDebug, depends on:
App in App (explicit)
"""
