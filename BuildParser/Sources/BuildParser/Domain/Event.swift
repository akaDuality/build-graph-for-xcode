import Foundation

public class Event: Equatable {
    
    
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
    
    public var parents: [Event] = []
    
    public static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.taskName == rhs.taskName
        // TODO: Add data
    }
}

extension Event: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(taskName) with \(steps.count) steps"
    }
}
