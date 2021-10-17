import Foundation

struct ReportOld: Codable {
    let metrics: ReportMetrics
    let actions: Actions
    var tests: TestsRef?
}

struct Actions: Codable {
    let _values: [ActionRecord]
}

struct ActionRecord: Codable {
    let actionResult: ActionResult
}

struct ActionResult: Codable {
    let testsRef: Ref?
}

struct Ref: Codable {
    let id: Metric
}
