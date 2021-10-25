import Foundation

public struct Event: Equatable {
    public init(taskName: String,
                startDate: Date,
                endDate: Date,
                steps: [Event]) {
        self.taskName = taskName
        self.startDate = startDate
        self.endDate = endDate
        self.steps = steps
    }
    
    public let taskName: String
    public let startDate: Date
    public let endDate: Date
    public let steps: [Event]
}
