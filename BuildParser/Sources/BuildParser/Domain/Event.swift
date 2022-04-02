import Foundation

public class Event: Equatable, Hashable {
    
    public init(taskName: String,
                startDate: Date,
                duration: TimeInterval,
                fetchedFromCache: Bool,
                steps: [Event]) {
        self.taskName = taskName
        self.startDate = startDate
        self.duration = duration
        self.fetchedFromCache = fetchedFromCache
        self.steps = steps
    }
    
    public let taskName: String
    public let startDate: Date
    public let duration: TimeInterval
    public lazy var endDate: Date = {
        startDate.addingTimeInterval(duration)
    }()
    
    public let fetchedFromCache: Bool
    public let steps: [Event]
    
    public var parents: [Event] = []
    
    public static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.taskName == rhs.taskName
        // TODO: Add data
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(taskName)
    }
}

extension Event: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(taskName) with \(steps.count) steps"
    }
}
