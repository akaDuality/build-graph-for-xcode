//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 24.05.2021.
//

import Foundation

struct Test {
    let suit: String
    let name: String
}

struct Suit {
    let name: String
    let tests: [String]
}

struct SuitDescr {
    let name: String
    let tests: String
}

func suitTests(_ suit: [String]) -> String {
    suit.map({ test in
        "❌ \(test)"
    }).joined(separator: "\n")
}


struct Report: Codable {
    let issues: Issues
    let metrics: Metrics
    
    func failedNames() throws -> [String] {
        return issues.testFailureSummaries?._values.compactMap { value in
            return value.testCaseName._value
        } ?? []
    }
    
    func summary() -> String {
        let countOfTests = metrics.testsCount._value
        let countOfFailureTests = metrics.testsFailedCount?._value ?? "0"
        let result = "Total: \(countOfTests), Failed: \(countOfFailureTests)"
        return result
    }

    func total() -> String {
         metrics.testsCount._value
    }

    func failed() -> String {
        metrics.testsFailedCount?._value ?? "0"
    }

    func skipped() -> String {
        metrics.testsSkippedCount?._value ?? "0"
    }
}

struct Issues: Codable {
    let testFailureSummaries: TestFailureSummaries?
}

struct TestFailureSummaries: Codable {
    let _values: [FailureValue]
}

struct FailureValue: Codable {
    let testCaseName: TestCaseName
}

struct TestCaseName: Codable {
    let _value: String
}

// metrics for func summary
struct Metrics: Codable {
    let testsCount: TestsCount
    let testsFailedCount: TestsFailedCount?
    let testsSkippedCount: TestsSkippedCount?
}

struct TestsCount: Codable {
    let _value: String
}

struct TestsFailedCount: Codable {
    let _value: String
}

struct TestsSkippedCount: Codable {
    let _value: String
}
