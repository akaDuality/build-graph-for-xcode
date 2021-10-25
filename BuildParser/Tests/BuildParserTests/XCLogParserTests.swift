//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 25.10.2021.
//

import Foundation
import XCTest
import BuildParser

class XCLogParserTests: XCTestCase {
    
    func test_realBuildLogParser() throws {
        let events = try RealBuildLogParser().parse(projectName: "DodoPizza")
        
        XCTAssertEqual(events.count, 92)
        
        //        for substep in buildSteps.subSteps {
        //            print("\(substep.title), \(substep.duration)")
        //        }
    }
}
