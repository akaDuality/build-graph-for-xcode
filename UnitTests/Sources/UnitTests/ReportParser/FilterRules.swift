import Foundation

typealias FilterRule = (String) -> Bool
struct FilterRules {
    static let specUnitRule: FilterRule = { $0.lowercased().contains("spec") }
    static let snapshotsTestRule: FilterRule = { $0.lowercased().contains("snapshot") }
    static let integrTestRule: FilterRule = { $0.lowercased().contains("integration") }
}

extension Array where Element == String {
    func applyFilter(_ rule: FilterRule) -> Self {
        self.filter{ rule($0) }
    }
}
