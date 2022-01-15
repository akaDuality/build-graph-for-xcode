//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import XCTest
@testable import BuildParser

final class EventTest: XCTestCase {
    func event(name: String) -> Event {
        Event(taskName: name,
              startDate: Date(),
              endDate: Date(),
              steps: [])
    }
    
    func test_ClearDomain() {
        let event = event(name: "Crypto")
        XCTAssertEqual(event.domain, "Crypto")
        XCTAssertEqual(event.type, .framework)
    }
    
    func test_HelpersDomain() {
        let event = event(name: "CryptoTestHelpers")
        XCTAssertEqual(event.domain, "Crypto")
        XCTAssertEqual(event.type, .helpers)
    }
    
    func test_TestDomain() {
        let event = event(name: "CryptoTestHelpers-Unit-Tests")
        XCTAssertEqual(event.domain, "Crypto")
        XCTAssertEqual(event.type, .tests)
    }
}
