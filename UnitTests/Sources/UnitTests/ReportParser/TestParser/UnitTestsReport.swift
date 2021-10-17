//
//  UnitTestReport.swift
//  
//
//  Created by Mikhail Rubanov on 06.06.2021.
//

import XMLCoder
import Foundation

/// Search for slowest tests
class UnitTestParser: FileParser {
    func parse() -> TestSuites {
        try! XMLDecoder().decode(TestSuites.self,
                                 from: data())
    }
    
    let threeshold: TimeInterval = 0.1
    func analyze(report: TestSuites) {
        let times = report.testsuite
            .filter({ suite in
                suite.totalTime > threeshold
            })
            .sorted(by: { suite1, suite2 in
                suite1.totalTime > suite2.totalTime
            })
            
            .map { suite in
                (suite.name, suite.totalTime)
            }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 3
        
        for time in times {
            let number = numberFormatter.string(from: NSNumber(value: time.1))!
            print("\(number) \(time.0)")
        }
        
        let longestTime = times
            .map({ (String, timeInterval) in
                timeInterval
            })
            .reduce(0, +)
        
        let totalTime = report.testsuite.reduce(0) { result, suite in
            result + suite.totalTime
        }
        print("\(times.count) spent \(longestTime), total: \(totalTime), \(longestTime/totalTime)")
    }
}

struct TestSuites: Codable {
    let name: String
    let tests: Int
    let failures: Int
    
    let testsuite: [TestSuite]
    var totalTime: TimeInterval {
        testsuite.reduce(0) { result, suite in
            result + suite.totalTime
        }
    }
}

struct TestSuite: Codable {
    let name: String
    let testcase: [TestCase]
    
    var totalTime: TimeInterval {
        testcase.reduce(0) { result, testcase in
            result + testcase.time
        }
    }
}

struct TestCase: Codable {
    let classname: String
    let name: String
    let time: TimeInterval
}
