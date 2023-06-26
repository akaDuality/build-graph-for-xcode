//
//  DurationFormatterTest.swift
//  
//
//  Created by Mikhail Rubanov on 23.02.2022.
//

import XCTest
import BuildParser

class DurationFormatterTest: XCTestCase {
    
    let formatter = DurationFormatter()
    
    func test_0sec() {
        XCTAssertEqual(formatter.string(from: 0), "")
    }
    
    func test_0_00001sec() {
        XCTAssertEqual(formatter.string(from: 0.00001), "< 1ms")
    }
    
    func test_0_001sec() {
        XCTAssertEqual(formatter.string(from: 0.001), "< 1ms")
    }
    
    func test_0_010004sec_shouldRoundUpTo0_01() {
        XCTAssertEqual(formatter.string(from: 0.01004), "0.01s")
    }
    
    func test_0_01sec() {
        XCTAssertEqual(formatter.string(from: 0.01), "0.01s")
    }
    
    func test_0_1sec() {
        XCTAssertEqual(formatter.string(from: 0.1), "0.1s")
    }
    
    func test_1sec() {
        XCTAssertEqual(formatter.string(from: 1), "1s")
    }
    
    func test_60sec() {
        XCTAssertEqual(formatter.string(from: 60), "1m")
    }
    
    func test_64_1sec() {
        XCTAssertEqual(formatter.string(from: 64.1), "1m 4s")
    }
}
