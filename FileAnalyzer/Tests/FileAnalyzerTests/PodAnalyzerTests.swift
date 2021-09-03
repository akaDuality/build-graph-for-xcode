//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 02.09.2021.
//

@testable import FileAnalyzer

import XCTest

class PodAnalyzerTests: XCTestCase {
    func test() {
        PodAnalyzer().analyze()
    }
    
    func test_readPodfile() throws {
        let pathString = Bundle.module.path(forResource: "Podfile",
                                            ofType: "")!
        
        let path = try XCTUnwrap(URL(fileURLWithPath: pathString))
        let podfile = Podfile(path: path,
                              name: "Test")
        XCTAssertEqual(podfile.pods, ["SwiftLint", "libPhoneNumber-iOS", "BlackBox", "AppsFlyerFramework", "Quick", "Firebase/Performance", "NCallback", "SnapshotTesting", "FirebaseMessaging", "Crypto", "RTIconButton", "Nuke", "Nimble", "Firebase/Crashlytics", "NQueueTestHelpers", "NRequest", "PinLayout", "CryptoTestHelpers", "LKAlertController", "Acquirers", "InAppStory", "MBProgressHUD", "PREBorderView", "KVOController", "HCaptcha", "AcquirersTestHelpers", "NQueue", "FirebaseInstallations", "Bagel", "KeychainSwift", "NInjectTestHelpers", "Qase", "AssertEqualProperties", "Firebase/Analytics", "FirebaseDynamicLinks", "Threads", "NSpry", "Firebase", "NInject", "DeviceKit", "NCallbackTestHelpers", "SZTextView", "Firebase/RemoteConfig", "NRequestTestHelpers"])
        
        XCTAssertEqual(podfile.pods.count, 44)
    }
    
    func testSimplePod() {
        let result = PodfileReader().read(content: podSample)
        XCTAssertEqual(result, ["AppsFlyerFramework",
                                "Firebase",
                                "Firebase/Performance",
                                "libPhoneNumber-iOS"
        ])
    }
}

let podSample =
"""
def analytics_providers_pods
  pod 'AppsFlyerFramework'
  pod 'Firebase', '8.1.0'
  pod 'Firebase/Performance', '8.1.0'
  pod 'libPhoneNumber-iOS', :git => 'https://github.com/iziz/libPhoneNumber-iOS'
end
"""
