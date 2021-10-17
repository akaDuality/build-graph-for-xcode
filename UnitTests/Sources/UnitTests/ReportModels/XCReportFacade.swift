import Foundation

struct XCReportFacade {
    let report: ReportOld
    
    init(report: ReportOld) {
        self.report = report
    }
    
    var unitTestsCount: Int? {
        Int(report.metrics.testsCount?.value ?? "")
    }
    var warningsCount: Int? {
        Int(report.metrics.warningCount.value)
    }
    
    var testsRefId: String? {
        report.actions._values.first?.actionResult.testsRef?.id.value
    }
}


extension XCReportFacade: CustomDebugStringConvertible {
    var debugDescription: String {
        var descr = "\n- - - - - - - - - - - - - -\n\n"
        
        if let unitTests = unitTestsCount {
            descr.append("Unit Tests: \t\t \(unitTests) \n")
        }
        
        if let warningsCount = warningsCount {
            descr.append("Warnings: \t\t\t \(warningsCount) \n")
        }
        
        descr.append("\n- - - - - - - - - - - - - -\n")
        return descr
    }
}
