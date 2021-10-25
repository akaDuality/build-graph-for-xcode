import Foundation
import Interface

public class XcodeBuildTimesParser {
    public init() {}
    
    public func parse(path: URL) throws -> [Event] {
        let buildLog = try buildLog(path: path)
        
        var events = [Event]()
        for eventLog in buildLog.events {
            if eventLog.event == .start {
                let end = buildLog.events.first { dto in
                    dto.taskName == eventLog.taskName && dto.event == .end
                }!
                
                events.append(Event(taskName: eventLog.taskName,
                                    startDate: eventLog.date,
                                    endDate: end.date,
                                    steps: []))
                // TODO: remove from buildLog.events for speedup
            }
        }
        return events
    }
    
    func buildLog(path: URL) throws -> EventsDTO {
        let file = try Data(contentsOf: path)
        let decoder =  JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
        let buildLog = try decoder.decode(EventsDTO.self, from: file)
        return buildLog
    }
}

extension DateFormatter {
    public static let iso8601Full: DateFormatter = {
        dateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ") // TODO: what is SSS...
    }()
    
    public static let iso8601Full_Z: DateFormatter = {
        dateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ")
    }()
    
    static func dateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}
