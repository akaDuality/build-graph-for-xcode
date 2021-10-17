import Foundation

struct ReportMetrics: Codable {
    let errorCount: Metric?
    let testsCount: Metric?
    let testsFailedCount: Metric?
    let testsSkippedCount: Metric?
    let warningCount: Metric
}
