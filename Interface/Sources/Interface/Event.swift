import Foundation

public struct Event {
    public init(taskName: String,
                startDate: Date,
                endDate: Date) {
        self.taskName = taskName
        self.startDate = startDate
        self.endDate = endDate
    }
    
    public let taskName: String
    public let startDate: Date
    public let endDate: Date
}
