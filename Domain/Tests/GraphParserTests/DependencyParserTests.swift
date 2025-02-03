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
class DependencyParser_xcode14: XCTestCase {
    
    let Crypto = Target(target: "Crypto",
                        project: "Crypto")
    
    let CryptoSwift = Target(target: "CryptoSwift",
                             project: "CryptoSwift")
    
    let Acquirers = Target(target: "Acquirers",
                           project: "Acquirers")
    
    let libPhoneNumber_iOS = Target(target: "libPhoneNumber-iOS",
                                    project: "libPhoneNumber-iOS")
    
    func test_noDependency_Crypto() {
        let dependency = parseDependency("Crypto in Crypto, no dependencies")
        
        XCTAssertNoDifference(
            dependency,
            Dependency(target: Crypto,
                       dependencies: []))
    }
    
    func test_noDependency_Autocomplete() {
        
        let dependency = parseDependency("Acquirers in Acquirers, no dependencies")
        
        XCTAssertNoDifference(
            dependency,
            Dependency(target: Acquirers,
                       dependencies: []))
    }
    
    func test_1Dependency() throws {
        let dependency = parseDependency(
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
        
        let dependency = parseDependency(
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
        
        let dependency = parseDependency(
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
        let dependency = parseDependency(
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
    
    func test_fullFile_xcode14_2() {
        let dependencies = parseFile(xcode14_2)
        
        assertSnapshot(
            matching: dependencies,
            as: .description
        )
    }
    
    func parseDependency(_ input: String) -> Dependency {
        let strings = input.components(separatedBy: "\n")

        return DependencyParser().dependency(from: strings)!
    }
    
    func parseFile(_ input: String) -> [Dependency] {
        DependencyParser().parseFile(input)
    }
}

// MARK: Xcode 15 & Xcode 16
class DependencyParser_xcode15_16: XCTestCase {
    
    func test_noDependencies() {
        let depedencies = parseDependency("""
\'API\' in \'API\', no dependencies
""")
        
        XCTAssertNoDifference(
            depedencies,
            Dependency(target: Target(target: "API", project: "API"),
                       dependencies: [
                       ])
        )
    }
    
    func test_noDependenciesWithoutCommas() {
        let depedencies = parseDependency("""
BlackBox in BlackBox, no dependencies
""")
        
        XCTAssertNoDifference(
            depedencies,
            Dependency(target: Target(target: "BlackBox", project: "BlackBox"),
                       dependencies: [
                       ])
        )
    }
    
    func test_singleDependency() {
        let depedencies = parseDependency("""
Target \'BuildGraphDebug\' in project \'BuildGraphDebug\'
➜ Explicit dependency on target \'App\' in project \'App\'
""")
        
        XCTAssertNoDifference(
            depedencies,
            Dependency(target: Target(target: "BuildGraphDebug", project: "BuildGraphDebug"),
                       dependencies: [
                        Target(target: "App", project: "App")
                       ])
        )
    }
    
    func test_severalExplicitDependencies() {
        let depedencies = parseDependency("""
Target \'App\' in project \'App\'
➜ Explicit dependency on target \'App\' in project \'App\'
➜ Explicit dependency on target \'App_App\' in project \'App\'
➜ Explicit dependency on target \'UI\' in project \'UI\'
""")
        
        XCTAssertNoDifference(
            depedencies,
            Dependency(target: Target(target: "App", project: "App"),
                       dependencies: [
                        Target(target: "App", project: "App"),
                        Target(target: "App_App", project: "App"),
                        Target(target: "UI", project: "UI"),
                       ])
        )
    }
    
    func test_implicitDependencies() {
        let depedencies = parseDependency("""
➜ Implicit dependency on target \'SnapshotTesting\' in project \'swift-snapshot-testing\' via file \'SnapshotTesting.framework\' in build phase \'Copy Files\'
""")
        
        XCTAssertNoDifference(
            depedencies,
            Dependency(target: Target(target: "SnapshotTesting", project: "swift-snapshot-testing"),
                       dependencies: [
                       ])
        )
    }
    
    func test_fullFile_xcode15_16() {
        let dependencies = parseFile(xcode15_16)
        
        assertSnapshot(
            matching: dependencies,
            as: .description
        )
    }

    func parseDependency(_ input: String) -> Dependency {
        let strings = input.components(separatedBy: "\n")
        
        return DependencyParser15().dependency(from: strings)!
    }
    
    func parseFile(_ input: String) -> [Dependency] {
        DependencyParser15().parseFile(input)
    }
}

let xcode15_16 = """
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

let xcode14_2 = """
Target dependency graph (112 targets)\nBlackBox in BlackBox, no dependencies\nDCommon in DCommon-ios, no dependencies\nDFoundation in DFoundation, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nNQueue in NQueue, no dependencies\nNRequest in NRequest, depends on:\nNQueue in NQueue (implicit dependency via file \'NQueue.framework\' in build phase \'Link Binary\')\nDNetwork in DNetwork-ios, depends on:\nNRequest in NRequest (implicit dependency via file \'NRequest.framework\' in build phase \'Link Binary\')\nDBFoundation in DBFoundation, no dependencies\nDBUIKit in DBUIKit, depends on:\nDBFoundation in DBFoundation (implicit dependency via file \'DBFoundation.framework\' in build phase \'Link Binary\')\nDeviceKit in DeviceKit, no dependencies\nDomain in Domain, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDynamicType in DynamicType, no dependencies\nLists in Lists, no dependencies\nMBProgressHUD in MBProgressHUD, no dependencies\nNInject in NInject, no dependencies\nDUIKit in DUIKit, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDBFoundation in DBFoundation (implicit dependency via file \'DBFoundation.framework\' in build phase \'Link Binary\')\nDBUIKit in DBUIKit (implicit dependency via file \'DBUIKit.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDeviceKit in DeviceKit (implicit dependency via file \'DeviceKit.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nDynamicType in DynamicType (implicit dependency via file \'DynamicType.framework\' in build phase \'Link Binary\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Link Binary\')\nMBProgressHUD in MBProgressHUD (implicit dependency via file \'MBProgressHUD.framework\' in build phase \'Link Binary\')\nNInject in NInject (implicit dependency via file \'NInject.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nNQueue in NQueue (implicit dependency via file \'NQueue.framework\' in build phase \'Link Binary\')\nComponentPreview in ComponentPreview, no dependencies\nKustoPizza in KustoPizza, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDNetwork in DNetwork-ios (implicit dependency via file \'DNetwork.framework\' in build phase \'Link Binary\')\nKustoSDK in KustoSDK-ios, no dependencies\nDAnalytics in DAnalytics, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDNetwork in DNetwork-ios (implicit dependency via file \'DNetwork.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nKustoPizza in KustoPizza (implicit dependency via file \'KustoPizza.framework\' in build phase \'Link Binary\')\nKustoSDK in KustoSDK-ios (implicit dependency via file \'KustoSDK.framework\' in build phase \'Link Binary\')\nNQueue in NQueue (implicit dependency via file \'NQueue.framework\' in build phase \'Link Binary\')\nRime in Rime, depends on:\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nDesignSandbox in DesignSandbox, depends on:\nComponentPreview in ComponentPreview (implicit dependency via file \'ComponentPreview.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Link Binary\')\nRime in Rime (implicit dependency via file \'Rime.framework\' in build phase \'Link Binary\')\nSwCrypt in SwCrypt, no dependencies\nMobileBackend in MobileBackend, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDNetwork in DNetwork-ios (implicit dependency via file \'DNetwork.framework\' in build phase \'Link Binary\')\nNQueue in NQueue (implicit dependency via file \'NQueue.framework\' in build phase \'Link Binary\')\nSwCrypt in SwCrypt (implicit dependency via file \'SwCrypt.framework\' in build phase \'Link Binary\')\nFeatureToggles in FeatureToggles, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nPhone in Phone, depends on:\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nLocality in Locality, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nFeatureToggles in FeatureToggles (implicit dependency via file \'FeatureToggles.framework\' in build phase \'Link Binary\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Link Binary\')\nMBProgressHUD in MBProgressHUD (implicit dependency via file \'MBProgressHUD.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nPhone in Phone (implicit dependency via file \'Phone.framework\' in build phase \'Link Binary\')\nNuke in Nuke, no dependencies\nNiceBonusDomain in NiceBonus, depends on:\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nNiceBonusUI in NiceBonus, depends on:\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Link Binary\')\nOrderTracking in OrderTracking, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nDynamicType in DynamicType (implicit dependency via file \'DynamicType.framework\' in build phase \'Link Binary\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nNiceBonusDomain in NiceBonus (implicit dependency via file \'NiceBonusDomain.framework\' in build phase \'Link Binary\')\nNiceBonusUI in NiceBonus (implicit dependency via file \'NiceBonusUI.framework\' in build phase \'Link Binary\')\nParallaxEditor in ParallaxEditor, depends on:\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nAppSetup in AppSetup, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDNetwork in DNetwork-ios (implicit dependency via file \'DNetwork.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDesignSandbox in DesignSandbox (implicit dependency via file \'DesignSandbox.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nFeatureToggles in FeatureToggles (implicit dependency via file \'FeatureToggles.framework\' in build phase \'Link Binary\')\nLocality in Locality (implicit dependency via file \'Locality.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nNQueue in NQueue (implicit dependency via file \'NQueue.framework\' in build phase \'Link Binary\')\nNuke in Nuke (implicit dependency via file \'Nuke.framework\' in build phase \'Link Binary\')\nOrderTracking in OrderTracking (implicit dependency via file \'OrderTracking.framework\' in build phase \'Link Binary\')\nParallaxEditor in ParallaxEditor (implicit dependency via file \'ParallaxEditor.framework\' in build phase \'Link Binary\')\nPhone in Phone (implicit dependency via file \'Phone.framework\' in build phase \'Link Binary\')\nDPushNotifications in DPushNotifications, no dependencies\nMindboxDodo in MindboxDodo, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDNetwork in DNetwork-ios (implicit dependency via file \'DNetwork.framework\' in build phase \'Link Binary\')\nDPushNotifications in DPushNotifications (implicit dependency via file \'DPushNotifications.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nMindBoxNotification in DodoPizza, depends on:\nAppSetup in AppSetup (implicit dependency via file \'AppSetup.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Link Binary\')\nDNetwork in DNetwork-ios (implicit dependency via file \'DNetwork.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nMindboxDodo in MindboxDodo (implicit dependency via file \'MindboxDodo.framework\' in build phase \'Link Binary\')\nNQueue in NQueue (implicit dependency via file \'NQueue.framework\' in build phase \'Link Binary\')\nOrderTrackingLiveActivity in DodoPizza, depends on:\nOrderTracking in OrderTracking (implicit dependency via file \'OrderTracking.framework\' in build phase \'Link Binary\')\nRate in Rate, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDNetwork in DNetwork-ios (implicit dependency via file \'DNetwork.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nDynamicType in DynamicType (implicit dependency via file \'DynamicType.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nPushNotificationContentExtension in DodoPizza, depends on:\nAppSetup in AppSetup (implicit dependency via file \'AppSetup.framework\' in build phase \'Link Binary\')\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDNetwork in DNetwork-ios (implicit dependency via file \'DNetwork.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nKustoPizza in KustoPizza (implicit dependency via file \'KustoPizza.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nNQueue in NQueue (implicit dependency via file \'NQueue.framework\' in build phase \'Link Binary\')\nRate in Rate (implicit dependency via file \'Rate.framework\' in build phase \'Link Binary\')\nAuth in Auth, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nDynamicType in DynamicType (implicit dependency via file \'DynamicType.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nPhone in Phone (implicit dependency via file \'Phone.framework\' in build phase \'Link Binary\')\nAutocomplete in Autocomplete-ios, no dependencies\nDParsers in DParsers, depends on:\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nTokenInterface in card-encryption-ios, no dependencies\nTokenizationNetwork in card-encryption-ios, no dependencies\nCheckoutCom in card-encryption-ios, depends on:\nTokenInterface in card-encryption-ios (explicit)\nTokenizationNetwork in card-encryption-ios (explicit)\nEncrypting in card-encryption-ios, depends on:\nTokenInterface in card-encryption-ios (explicit)\nECommPay in card-encryption-ios, depends on:\nEncrypting in card-encryption-ios (explicit)\nTokenInterface in card-encryption-ios (explicit)\nTokenizationNetwork in card-encryption-ios (explicit)\nPaymentsOS in card-encryption-ios, depends on:\nTokenInterface in card-encryption-ios (explicit)\nTokenizationNetwork in card-encryption-ios (explicit)\nDAcquirers in card-encryption-ios, depends on:\nCheckoutCom in card-encryption-ios (explicit)\nECommPay in card-encryption-ios (explicit)\nEncrypting in card-encryption-ios (explicit)\nPaymentsOS in card-encryption-ios (explicit)\nState in State, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAcquirers in card-encryption-ios (implicit dependency via file \'DAcquirers.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDParsers in DParsers (implicit dependency via file \'DParsers.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nNiceBonusDomain in NiceBonus (implicit dependency via file \'NiceBonusDomain.framework\' in build phase \'Link Binary\')\nDeliveryLocation in DeliveryLocation, depends on:\nAutocomplete in Autocomplete-ios (implicit dependency via file \'Autocomplete.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nState in State (implicit dependency via file \'State.framework\' in build phase \'Link Binary\')\nGeolocation in Geolocation, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nDMapKit in DMapKit, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nGeolocation in Geolocation (implicit dependency via file \'Geolocation.framework\' in build phase \'Link Binary\')\nPizzeria in Pizzeria, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDMapKit in DMapKit (implicit dependency via file \'DMapKit.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nDynamicType in DynamicType (implicit dependency via file \'DynamicType.framework\' in build phase \'Link Binary\')\nGeolocation in Geolocation (implicit dependency via file \'Geolocation.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nPhone in Phone (implicit dependency via file \'Phone.framework\' in build phase \'Link Binary\')\nAddress in Address, depends on:\nAuth in Auth (implicit dependency via file \'Auth.framework\' in build phase \'Link Binary\')\nAutocomplete in Autocomplete-ios (implicit dependency via file \'Autocomplete.framework\' in build phase \'Link Binary\')\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDParsers in DParsers (implicit dependency via file \'DParsers.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDeliveryLocation in DeliveryLocation (implicit dependency via file \'DeliveryLocation.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nDynamicType in DynamicType (implicit dependency via file \'DynamicType.framework\' in build phase \'Link Binary\')\nLocality in Locality (implicit dependency via file \'Locality.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nPizzeria in Pizzeria (implicit dependency via file \'Pizzeria.framework\' in build phase \'Link Binary\')\nState in State (implicit dependency via file \'State.framework\' in build phase \'Link Binary\')\nCartDomain in Cart, depends on:\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\n_LottieStub in Lottie, no dependencies\nAddressRegulation in AddressRegulation, depends on:\nAuth in Auth (implicit dependency via file \'Auth.framework\' in build phase \'Link Binary\')\nCartDomain in Cart (implicit dependency via file \'CartDomain.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDMapKit in DMapKit (implicit dependency via file \'DMapKit.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDeliveryLocation in DeliveryLocation (implicit dependency via file \'DeliveryLocation.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Link Binary\')\nLocality in Locality (implicit dependency via file \'Locality.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nState in State (implicit dependency via file \'State.framework\' in build phase \'Link Binary\')\n_LottieStub in Lottie (implicit dependency via file \'_LottieStub.framework\' in build phase \'Link Binary\')\nAreYouInPizzeria in AreYouInPizzeria, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nGeolocation in Geolocation (implicit dependency via file \'Geolocation.framework\' in build phase \'Link Binary\')\nBonuses in Bonuses, depends on:\nAuth in Auth (implicit dependency via file \'Auth.framework\' in build phase \'Link Binary\')\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nState in State (implicit dependency via file \'State.framework\' in build phase \'Link Binary\')\nCart in Cart, depends on:\nCartDomain in Cart (explicit)\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nBonuses in Bonuses (implicit dependency via file \'Bonuses.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nDynamicType in DynamicType (implicit dependency via file \'DynamicType.framework\' in build phase \'Link Binary\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nNiceBonusUI in NiceBonus (implicit dependency via file \'NiceBonusUI.framework\' in build phase \'Link Binary\')\nState in State (implicit dependency via file \'State.framework\' in build phase \'Link Binary\')\nChat in Chat, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDPushNotifications in DPushNotifications (implicit dependency via file \'DPushNotifications.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nCheckAPI in CheckAPI, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nPhone in Phone (implicit dependency via file \'Phone.framework\' in build phase \'Link Binary\')\nPayment in Payment, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAcquirers in card-encryption-ios (implicit dependency via file \'DAcquirers.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nState in State (implicit dependency via file \'State.framework\' in build phase \'Link Binary\')\nCheckout in Checkout, depends on:\nAddress in Address (implicit dependency via file \'Address.framework\' in build phase \'Link Binary\')\nAuth in Auth (implicit dependency via file \'Auth.framework\' in build phase \'Link Binary\')\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAcquirers in card-encryption-ios (implicit dependency via file \'DAcquirers.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDeliveryLocation in DeliveryLocation (implicit dependency via file \'DeliveryLocation.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nDynamicType in DynamicType (implicit dependency via file \'DynamicType.framework\' in build phase \'Link Binary\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Link Binary\')\nLocality in Locality (implicit dependency via file \'Locality.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nPayment in Payment (implicit dependency via file \'Payment.framework\' in build phase \'Link Binary\')\nPizzeria in Pizzeria (implicit dependency via file \'Pizzeria.framework\' in build phase \'Link Binary\')\nState in State (implicit dependency via file \'State.framework\' in build phase \'Link Binary\')\nCityLanding in CityLanding, depends on:\nAuth in Auth (implicit dependency via file \'Auth.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nPhone in Phone (implicit dependency via file \'Phone.framework\' in build phase \'Link Binary\')\nDSecurity in DSecurity, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nDeliveryLocationUI in DeliveryLocationUI, depends on:\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDeliveryLocation in DeliveryLocation (implicit dependency via file \'DeliveryLocation.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nInAppNotifications in InAppNotifications, depends on:\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDNetwork in DNetwork-ios (implicit dependency via file \'DNetwork.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nLoyalty in Loyalty, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDNetwork in DNetwork-ios (implicit dependency via file \'DNetwork.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nDynamicType in DynamicType (implicit dependency via file \'DynamicType.framework\' in build phase \'Link Binary\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nMapAddressSelectionOld in MapAddressSelectionOld, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDMapKit in DMapKit (implicit dependency via file \'DMapKit.framework\' in build phase \'Link Binary\')\nDNetwork in DNetwork-ios (implicit dependency via file \'DNetwork.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nGeolocation in Geolocation (implicit dependency via file \'Geolocation.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nStories in Stories, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nMenu in Menu, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nDynamicType in DynamicType (implicit dependency via file \'DynamicType.framework\' in build phase \'Link Binary\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nNQueue in NQueue (implicit dependency via file \'NQueue.framework\' in build phase \'Link Binary\')\nOrderTracking in OrderTracking (implicit dependency via file \'OrderTracking.framework\' in build phase \'Link Binary\')\nRime in Rime (implicit dependency via file \'Rime.framework\' in build phase \'Link Binary\')\nState in State (implicit dependency via file \'State.framework\' in build phase \'Link Binary\')\nStories in Stories (implicit dependency via file \'Stories.framework\' in build phase \'Link Binary\')\nMenuSearch in MenuSearch, depends on:\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Link Binary\')\nMenu in Menu (implicit dependency via file \'Menu.framework\' in build phase \'Link Binary\')\nMissions in Missions, depends on:\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDNetwork in DNetwork-ios (implicit dependency via file \'DNetwork.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\n_LottieStub in Lottie (implicit dependency via file \'_LottieStub.framework\' in build phase \'Link Binary\')\nNiceBonus in NiceBonus, depends on:\nNiceBonusDomain in NiceBonus (explicit)\nNiceBonusUI in NiceBonus (explicit)\nCartDomain in Cart (implicit dependency via file \'CartDomain.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Link Binary\')\nState in State (implicit dependency via file \'State.framework\' in build phase \'Link Binary\')\nOrderHistoryDomain in OrderHistory, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nOrderHistory in OrderHistory, depends on:\nOrderHistoryDomain in OrderHistory (explicit)\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nDynamicType in DynamicType (implicit dependency via file \'DynamicType.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nProduct in Product, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Link Binary\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Link Binary\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Link Binary\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Link Binary\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Link Binary\')\nMenu in Menu (implicit dependency via file \'Menu.framework\' in build phase \'Link Binary\')\nServicePush in ServicePush, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nDPushNotifications in DPushNotifications (implicit dependency via file \'DPushNotifications.framework\' in build phase \'Link Binary\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Link Binary\')\nFirebase in Firebase, no dependencies\nGoogleUtilities-NSData in GoogleUtilities, no dependencies\nFirebaseCoreInternal in Firebase, depends on:\nGoogleUtilities-NSData in GoogleUtilities (implicit dependency via file \'GoogleUtilities_NSData.framework\' in build phase \'Copy Files\')\nFBLPromises in Promises, no dependencies\nGoogleUtilities-Environment in GoogleUtilities, depends on:\nFBLPromises in Promises (implicit dependency via file \'FBLPromises.framework\' in build phase \'Copy Files\')\nGoogleUtilities-Logger in GoogleUtilities, depends on:\nGoogleUtilities-Environment in GoogleUtilities (explicit)\nFirebaseCore in Firebase, depends on:\nFirebase in Firebase (explicit)\nFirebaseCoreInternal in Firebase (explicit)\nGoogleUtilities-Environment in GoogleUtilities (implicit dependency via file \'GoogleUtilities_Environment.framework\' in build phase \'Copy Files\')\nGoogleUtilities-Logger in GoogleUtilities (implicit dependency via file \'GoogleUtilities_Logger.framework\' in build phase \'Copy Files\')\nGoogleUtilities-UserDefaults in GoogleUtilities, depends on:\nGoogleUtilities-Logger in GoogleUtilities (explicit)\nFirebaseInstallations in Firebase, depends on:\nFirebaseCore in Firebase (explicit)\nFBLPromises in Promises (implicit dependency via file \'FBLPromises.framework\' in build phase \'Copy Files\')\nGoogleUtilities-Environment in GoogleUtilities (implicit dependency via file \'GoogleUtilities_Environment.framework\' in build phase \'Copy Files\')\nGoogleUtilities-UserDefaults in GoogleUtilities (implicit dependency via file \'GoogleUtilities_UserDefaults.framework\' in build phase \'Copy Files\')\nnanopb in nanopb, no dependencies\nGoogleDataTransport in GoogleDataTransport, depends on:\nFBLPromises in Promises (implicit dependency via file \'FBLPromises.framework\' in build phase \'Copy Files\')\nGoogleUtilities-Environment in GoogleUtilities (implicit dependency via file \'GoogleUtilities_Environment.framework\' in build phase \'Copy Files\')\nnanopb in nanopb (implicit dependency via file \'nanopb.framework\' in build phase \'Copy Files\')\nFirebaseCrashlytics in Firebase, depends on:\nFirebaseCore in Firebase (explicit)\nFirebaseInstallations in Firebase (explicit)\nFBLPromises in Promises (implicit dependency via file \'FBLPromises.framework\' in build phase \'Copy Files\')\nGoogleDataTransport in GoogleDataTransport (implicit dependency via file \'GoogleDataTransport.framework\' in build phase \'Copy Files\')\nGoogleUtilities-Environment in GoogleUtilities (implicit dependency via file \'GoogleUtilities_Environment.framework\' in build phase \'Copy Files\')\nnanopb in nanopb (implicit dependency via file \'nanopb.framework\' in build phase \'Copy Files\')\nBlackBoxFirebaseCrashlytics in BlackBoxFirebaseCrashlytics, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nFirebaseCrashlytics in Firebase (implicit dependency via file \'FirebaseCrashlytics.framework\' in build phase \'Copy Files\')\nFirebaseABTesting in Firebase, depends on:\nFirebaseCore in Firebase (explicit)\nFirebaseRemoteConfig in Firebase, depends on:\nFirebaseABTesting in Firebase (explicit)\nFirebaseCore in Firebase (explicit)\nFirebaseInstallations in Firebase (explicit)\nGoogleUtilities-NSData in GoogleUtilities (implicit dependency via file \'GoogleUtilities_NSData.framework\' in build phase \'Copy Files\')\nGoogleUtilities-ISASwizzler in GoogleUtilities, depends on:\nGoogleUtilities-Logger in GoogleUtilities (explicit)\nGoogleUtilities-MethodSwizzler in GoogleUtilities, depends on:\nGoogleUtilities-Logger in GoogleUtilities (explicit)\nFirebasePerformance in Firebase, depends on:\nFirebaseCore in Firebase (explicit)\nFirebaseInstallations in Firebase (explicit)\nFirebaseRemoteConfig in Firebase (explicit)\nGoogleDataTransport in GoogleDataTransport (implicit dependency via file \'GoogleDataTransport.framework\' in build phase \'Copy Files\')\nGoogleUtilities-Environment in GoogleUtilities (implicit dependency via file \'GoogleUtilities_Environment.framework\' in build phase \'Copy Files\')\nGoogleUtilities-ISASwizzler in GoogleUtilities (implicit dependency via file \'GoogleUtilities_ISASwizzler.framework\' in build phase \'Copy Files\')\nGoogleUtilities-MethodSwizzler in GoogleUtilities (implicit dependency via file \'GoogleUtilities_MethodSwizzler.framework\' in build phase \'Copy Files\')\nGoogleUtilities-UserDefaults in GoogleUtilities (implicit dependency via file \'GoogleUtilities_UserDefaults.framework\' in build phase \'Copy Files\')\nnanopb in nanopb (implicit dependency via file \'nanopb.framework\' in build phase \'Copy Files\')\nFirebasePerformanceTarget in Firebase, depends on:\nFirebasePerformance in Firebase (explicit)\nBlackBoxFirebasePerformance in BlackBoxFirebasePerformance, depends on:\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nFirebasePerformanceTarget in Firebase (implicit dependency via file \'FirebasePerformanceTarget.framework\' in build phase \'Copy Files\')\nBlackBoxKusto_BlackBoxKusto in BlackBoxKusto, no dependencies\nBlackBoxKusto in BlackBoxKusto, depends on:\nBlackBoxKusto_BlackBoxKusto in BlackBoxKusto (explicit)\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Link Binary\')\nGoogleUtilities-Reachability in GoogleUtilities, depends on:\nGoogleUtilities-Logger in GoogleUtilities (explicit)\nGoogleUtilities-Network in GoogleUtilities, depends on:\nGoogleUtilities-Logger in GoogleUtilities (explicit)\nGoogleUtilities-NSData in GoogleUtilities (explicit)\nGoogleUtilities-Reachability in GoogleUtilities (explicit)\nGoogleUtilities-AppDelegateSwizzler in GoogleUtilities, depends on:\nGoogleUtilities-Environment in GoogleUtilities (explicit)\nGoogleUtilities-Logger in GoogleUtilities (explicit)\nGoogleUtilities-Network in GoogleUtilities (explicit)\nGoogleAppMeasurementTarget in GoogleAppMeasurement, depends on:\nGoogleUtilities-AppDelegateSwizzler in GoogleUtilities (implicit dependency via file \'GoogleUtilities_AppDelegateSwizzler.framework\' in build phase \'Copy Files\')\nGoogleUtilities-MethodSwizzler in GoogleUtilities (implicit dependency via file \'GoogleUtilities_MethodSwizzler.framework\' in build phase \'Copy Files\')\nGoogleUtilities-NSData in GoogleUtilities (implicit dependency via file \'GoogleUtilities_NSData.framework\' in build phase \'Copy Files\')\nGoogleUtilities-Network in GoogleUtilities (implicit dependency via file \'GoogleUtilities_Network.framework\' in build phase \'Copy Files\')\nnanopb in nanopb (implicit dependency via file \'nanopb.framework\' in build phase \'Copy Files\')\nFirebaseAnalyticsWrapper in Firebase, depends on:\nFirebaseCore in Firebase (explicit)\nFirebaseInstallations in Firebase (explicit)\nGoogleAppMeasurementTarget in GoogleAppMeasurement (implicit dependency via file \'GoogleAppMeasurementTarget.framework\' in build phase \'Copy Files\')\nGoogleUtilities-AppDelegateSwizzler in GoogleUtilities (implicit dependency via file \'GoogleUtilities_AppDelegateSwizzler.framework\' in build phase \'Copy Files\')\nGoogleUtilities-MethodSwizzler in GoogleUtilities (implicit dependency via file \'GoogleUtilities_MethodSwizzler.framework\' in build phase \'Copy Files\')\nGoogleUtilities-NSData in GoogleUtilities (implicit dependency via file \'GoogleUtilities_NSData.framework\' in build phase \'Copy Files\')\nGoogleUtilities-Network in GoogleUtilities (implicit dependency via file \'GoogleUtilities_Network.framework\' in build phase \'Copy Files\')\nnanopb in nanopb (implicit dependency via file \'nanopb.framework\' in build phase \'Copy Files\')\nFirebaseAnalyticsTarget in Firebase, depends on:\nFirebaseAnalyticsWrapper in Firebase (explicit)\nFirebaseDynamicLinks in Firebase, depends on:\nFirebaseCore in Firebase (explicit)\nFirebaseDynamicLinksTarget in Firebase, depends on:\nFirebaseDynamicLinks in Firebase (explicit)\nFirebaseMessaging in Firebase, depends on:\nFirebaseCore in Firebase (explicit)\nFirebaseInstallations in Firebase (explicit)\nGoogleDataTransport in GoogleDataTransport (implicit dependency via file \'GoogleDataTransport.framework\' in build phase \'Copy Files\')\nGoogleUtilities-AppDelegateSwizzler in GoogleUtilities (implicit dependency via file \'GoogleUtilities_AppDelegateSwizzler.framework\' in build phase \'Copy Files\')\nGoogleUtilities-Environment in GoogleUtilities (implicit dependency via file \'GoogleUtilities_Environment.framework\' in build phase \'Copy Files\')\nGoogleUtilities-Reachability in GoogleUtilities (implicit dependency via file \'GoogleUtilities_Reachability.framework\' in build phase \'Copy Files\')\nGoogleUtilities-UserDefaults in GoogleUtilities (implicit dependency via file \'GoogleUtilities_UserDefaults.framework\' in build phase \'Copy Files\')\nnanopb in nanopb (implicit dependency via file \'nanopb.framework\' in build phase \'Copy Files\')\nDodoPizza in DodoPizza, depends on:\nMindBoxNotification in DodoPizza (explicit)\nOrderTrackingLiveActivity in DodoPizza (explicit)\nPushNotificationContentExtension in DodoPizza (explicit)\nAddress in Address (implicit dependency via file \'Address.framework\' in build phase \'Copy Files\')\nAddressRegulation in AddressRegulation (implicit dependency via file \'AddressRegulation.framework\' in build phase \'Copy Files\')\nAppSetup in AppSetup (implicit dependency via file \'AppSetup.framework\' in build phase \'Copy Files\')\nAreYouInPizzeria in AreYouInPizzeria (implicit dependency via file \'AreYouInPizzeria.framework\' in build phase \'Copy Files\')\nAuth in Auth (implicit dependency via file \'Auth.framework\' in build phase \'Copy Files\')\nAutocomplete in Autocomplete-ios (implicit dependency via file \'Autocomplete.framework\' in build phase \'Copy Files\')\nBlackBox in BlackBox (implicit dependency via file \'BlackBox.framework\' in build phase \'Copy Files\')\nBonuses in Bonuses (implicit dependency via file \'Bonuses.framework\' in build phase \'Copy Files\')\nCart in Cart (implicit dependency via file \'Cart.framework\' in build phase \'Copy Files\')\nCartDomain in Cart (implicit dependency via file \'CartDomain.framework\' in build phase \'Copy Files\')\nChat in Chat (implicit dependency via file \'Chat.framework\' in build phase \'Copy Files\')\nCheckAPI in CheckAPI (implicit dependency via file \'CheckAPI.framework\' in build phase \'Copy Files\')\nCheckout in Checkout (implicit dependency via file \'Checkout.framework\' in build phase \'Copy Files\')\nCheckoutCom in card-encryption-ios (implicit dependency via file \'CheckoutCom.framework\' in build phase \'Copy Files\')\nCityLanding in CityLanding (implicit dependency via file \'CityLanding.framework\' in build phase \'Copy Files\')\nComponentPreview in ComponentPreview (implicit dependency via file \'ComponentPreview.framework\' in build phase \'Copy Files\')\nDAcquirers in card-encryption-ios (implicit dependency via file \'DAcquirers.framework\' in build phase \'Copy Files\')\nDAnalytics in DAnalytics (implicit dependency via file \'DAnalytics.framework\' in build phase \'Copy Files\')\nDBFoundation in DBFoundation (implicit dependency via file \'DBFoundation.framework\' in build phase \'Copy Files\')\nDBUIKit in DBUIKit (implicit dependency via file \'DBUIKit.framework\' in build phase \'Copy Files\')\nDCommon in DCommon-ios (implicit dependency via file \'DCommon.framework\' in build phase \'Copy Files\')\nDFoundation in DFoundation (implicit dependency via file \'DFoundation.framework\' in build phase \'Copy Files\')\nDMapKit in DMapKit (implicit dependency via file \'DMapKit.framework\' in build phase \'Copy Files\')\nDNetwork in DNetwork-ios (implicit dependency via file \'DNetwork.framework\' in build phase \'Copy Files\')\nDParsers in DParsers (implicit dependency via file \'DParsers.framework\' in build phase \'Copy Files\')\nDPushNotifications in DPushNotifications (implicit dependency via file \'DPushNotifications.framework\' in build phase \'Copy Files\')\nDSecurity in DSecurity (implicit dependency via file \'DSecurity.framework\' in build phase \'Copy Files\')\nDUIKit in DUIKit (implicit dependency via file \'DUIKit.framework\' in build phase \'Copy Files\')\nDataPersistence in DataPersistence (implicit dependency via file \'DataPersistence.framework\' in build phase \'Copy Files\')\nDeliveryLocation in DeliveryLocation (implicit dependency via file \'DeliveryLocation.framework\' in build phase \'Copy Files\')\nDeliveryLocationUI in DeliveryLocationUI (implicit dependency via file \'DeliveryLocationUI.framework\' in build phase \'Copy Files\')\nDesignSandbox in DesignSandbox (implicit dependency via file \'DesignSandbox.framework\' in build phase \'Copy Files\')\nDeviceKit in DeviceKit (implicit dependency via file \'DeviceKit.framework\' in build phase \'Copy Files\')\nDomain in Domain (implicit dependency via file \'Domain.framework\' in build phase \'Copy Files\')\nDynamicType in DynamicType (implicit dependency via file \'DynamicType.framework\' in build phase \'Copy Files\')\nECommPay in card-encryption-ios (implicit dependency via file \'ECommPay.framework\' in build phase \'Copy Files\')\nEncrypting in card-encryption-ios (implicit dependency via file \'Encrypting.framework\' in build phase \'Copy Files\')\nFeatureToggles in FeatureToggles (implicit dependency via file \'FeatureToggles.framework\' in build phase \'Copy Files\')\nGeolocation in Geolocation (implicit dependency via file \'Geolocation.framework\' in build phase \'Copy Files\')\nInAppNotifications in InAppNotifications (implicit dependency via file \'InAppNotifications.framework\' in build phase \'Copy Files\')\nKustoPizza in KustoPizza (implicit dependency via file \'KustoPizza.framework\' in build phase \'Copy Files\')\nLists in Lists (implicit dependency via file \'Lists.framework\' in build phase \'Copy Files\')\nLocality in Locality (implicit dependency via file \'Locality.framework\' in build phase \'Copy Files\')\nLoyalty in Loyalty (implicit dependency via file \'Loyalty.framework\' in build phase \'Copy Files\')\nMapAddressSelectionOld in MapAddressSelectionOld (implicit dependency via file \'MapAddressSelectionOld.framework\' in build phase \'Copy Files\')\nMenu in Menu (implicit dependency via file \'Menu.framework\' in build phase \'Copy Files\')\nMenuSearch in MenuSearch (implicit dependency via file \'MenuSearch.framework\' in build phase \'Copy Files\')\nMindboxDodo in MindboxDodo (implicit dependency via file \'MindboxDodo.framework\' in build phase \'Copy Files\')\nMissions in Missions (implicit dependency via file \'Missions.framework\' in build phase \'Copy Files\')\nMobileBackend in MobileBackend (implicit dependency via file \'MobileBackend.framework\' in build phase \'Copy Files\')\nNQueue in NQueue (implicit dependency via file \'NQueue.framework\' in build phase \'Copy Files\')\nNRequest in NRequest (implicit dependency via file \'NRequest.framework\' in build phase \'Copy Files\')\nNiceBonus in NiceBonus (implicit dependency via file \'NiceBonus.framework\' in build phase \'Copy Files\')\nNiceBonusDomain in NiceBonus (implicit dependency via file \'NiceBonusDomain.framework\' in build phase \'Copy Files\')\nNiceBonusUI in NiceBonus (implicit dependency via file \'NiceBonusUI.framework\' in build phase \'Copy Files\')\nOrderHistory in OrderHistory (implicit dependency via file \'OrderHistory.framework\' in build phase \'Copy Files\')\nOrderHistoryDomain in OrderHistory (implicit dependency via file \'OrderHistoryDomain.framework\' in build phase \'Copy Files\')\nOrderTracking in OrderTracking (implicit dependency via file \'OrderTracking.framework\' in build phase \'Copy Files\')\nParallaxEditor in ParallaxEditor (implicit dependency via file \'ParallaxEditor.framework\' in build phase \'Copy Files\')\nPayment in Payment (implicit dependency via file \'Payment.framework\' in build phase \'Copy Files\')\nPaymentsOS in card-encryption-ios (implicit dependency via file \'PaymentsOS.framework\' in build phase \'Copy Files\')\nPhone in Phone (implicit dependency via file \'Phone.framework\' in build phase \'Copy Files\')\nPizzeria in Pizzeria (implicit dependency via file \'Pizzeria.framework\' in build phase \'Copy Files\')\nProduct in Product (implicit dependency via file \'Product.framework\' in build phase \'Copy Files\')\nRate in Rate (implicit dependency via file \'Rate.framework\' in build phase \'Copy Files\')\nRime in Rime (implicit dependency via file \'Rime.framework\' in build phase \'Copy Files\')\nServicePush in ServicePush (implicit dependency via file \'ServicePush.framework\' in build phase \'Copy Files\')\nState in State (implicit dependency via file \'State.framework\' in build phase \'Copy Files\')\nStories in Stories (implicit dependency via file \'Stories.framework\' in build phase \'Copy Files\')\nTokenInterface in card-encryption-ios (implicit dependency via file \'TokenInterface.framework\' in build phase \'Copy Files\')\nTokenizationNetwork in card-encryption-ios (implicit dependency via file \'TokenizationNetwork.framework\' in build phase \'Copy Files\')\n_LottieStub in Lottie (implicit dependency via file \'_LottieStub.framework\' in build phase \'Copy Files\')\nBlackBoxFirebaseCrashlytics in BlackBoxFirebaseCrashlytics (implicit dependency via file \'BlackBoxFirebaseCrashlytics.framework\' in build phase \'Link Binary\')\nBlackBoxFirebasePerformance in BlackBoxFirebasePerformance (implicit dependency via file \'BlackBoxFirebasePerformance.framework\' in build phase \'Link Binary\')\nBlackBoxKusto in BlackBoxKusto (implicit dependency via file \'BlackBoxKusto.framework\' in build phase \'Link Binary\')\nFBLPromises in Promises (implicit dependency via file \'FBLPromises.framework\' in build phase \'Link Binary\')\nFirebase in Firebase (implicit dependency via file \'Firebase.framework\' in build phase \'Link Binary\')\nFirebaseABTesting in Firebase (implicit dependency via file \'FirebaseABTesting.framework\' in build phase \'Link Binary\')\nFirebaseAnalyticsTarget in Firebase (implicit dependency via file \'FirebaseAnalyticsTarget.framework\' in build phase \'Link Binary\')\nFirebaseAnalyticsWrapper in Firebase (implicit dependency via file \'FirebaseAnalyticsWrapper.framework\' in build phase \'Link Binary\')\nFirebaseCore in Firebase (implicit dependency via file \'FirebaseCore.framework\' in build phase \'Link Binary\')\nFirebaseCoreInternal in Firebase (implicit dependency via file \'FirebaseCoreInternal.framework\' in build phase \'Link Binary\')\nFirebaseCrashlytics in Firebase (implicit dependency via file \'FirebaseCrashlytics.framework\' in build phase \'Link Binary\')\nFirebaseDynamicLinks in Firebase (implicit dependency via file \'FirebaseDynamicLinks.framework\' in build phase \'Link Binary\')\nFirebaseDynamicLinksTarget in Firebase (implicit dependency via file \'FirebaseDynamicLinksTarget.framework\' in build phase \'Link Binary\')\nFirebaseInstallations in Firebase (implicit dependency via file \'FirebaseInstallations.framework\' in build phase \'Link Binary\')\nFirebaseMessaging in Firebase (implicit dependency via file \'FirebaseMessaging.framework\' in build phase \'Link Binary\')\nFirebasePerformance in Firebase (implicit dependency via file \'FirebasePerformance.framework\' in build phase \'Link Binary\')\nFirebasePerformanceTarget in Firebase (implicit dependency via file \'FirebasePerformanceTarget.framework\' in build phase \'Link Binary\')\nFirebaseRemoteConfig in Firebase (implicit dependency via file \'FirebaseRemoteConfig.framework\' in build phase \'Link Binary\')\nGoogleAppMeasurementTarget in GoogleAppMeasurement (implicit dependency via file \'GoogleAppMeasurementTarget.framework\' in build phase \'Link Binary\')\nGoogleDataTransport in GoogleDataTransport (implicit dependency via file \'GoogleDataTransport.framework\' in build phase \'Link Binary\')\nGoogleUtilities-AppDelegateSwizzler in GoogleUtilities (implicit dependency via file \'GoogleUtilities_AppDelegateSwizzler.framework\' in build phase \'Link Binary\')\nGoogleUtilities-Environment in GoogleUtilities (implicit dependency via file \'GoogleUtilities_Environment.framework\' in build phase \'Link Binary\')\nGoogleUtilities-ISASwizzler in GoogleUtilities (implicit dependency via file \'GoogleUtilities_ISASwizzler.framework\' in build phase \'Link Binary\')\nGoogleUtilities-Logger in GoogleUtilities (implicit dependency via file \'GoogleUtilities_Logger.framework\' in build phase \'Link Binary\')\nGoogleUtilities-MethodSwizzler in GoogleUtilities (implicit dependency via file \'GoogleUtilities_MethodSwizzler.framework\' in build phase \'Link Binary\')\nGoogleUtilities-NSData in GoogleUtilities (implicit dependency via file \'GoogleUtilities_NSData.framework\' in build phase \'Link Binary\')\nGoogleUtilities-Network in GoogleUtilities (implicit dependency via file \'GoogleUtilities_Network.framework\' in build phase \'Link Binary\')\nGoogleUtilities-Reachability in GoogleUtilities (implicit dependency via file \'GoogleUtilities_Reachability.framework\' in build phase \'Link Binary\')\nGoogleUtilities-UserDefaults in GoogleUtilities (implicit dependency via file \'GoogleUtilities_UserDefaults.framework\' in build phase \'Link Binary\')\nMBProgressHUD in MBProgressHUD (implicit dependency via file \'MBProgressHUD.framework\' in build phase \'Link Binary\')\nnanopb in nanopb (implicit dependency via file \'nanopb.framework\' in build phase \'Link Binary\')\nBlackBoxKusto_BlackBoxKusto in BlackBoxKusto (implicit dependency via file \'BlackBoxKusto_BlackBoxKusto.bundle\' in build phase \'Copy Files\')
"""
