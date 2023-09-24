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
    public var startDate: Date // Can be moved in case of big gap
    public let duration: TimeInterval
    public var endDate: Date {
        startDate.addingTimeInterval(duration)
    }
    
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
    
    /// Parent check is heavy operation: a lot of string comparison and array allocations. Cache fix performance problems as a result
    public var parentCheckCache = [String: Bool]()
    
    public lazy var durationDescription: String = eventDescriptionFormatter.string(from: duration)
    
    public var fontSizeCache = [CGFloat: CGSize]()
}

private let eventDescriptionFormatter  = DurationFormatter()

extension Event: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(taskName) with \(steps.count) steps"
    }
}
