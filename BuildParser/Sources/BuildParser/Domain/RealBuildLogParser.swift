//
//  RealBuildLogParser.swift
//  
//
//  Created by Mikhail Rubanov on 25.10.2021.
//

import XCLogParser
import Interface
import Foundation

public class RealBuildLogParser {
    let logFinder = LogFinder()
    let activityLogParser = ActivityParser()
   
    public init() {}
    
    public func parse() throws -> [Event] {
        let logOptions = LogOptions(
//            projectName: "DodoPizza",
//            xcworkspacePath: "/Users/rubanov/Documents/Projects/dodo-mobile-ios/DodoPizza/DodoPizza.xcworkspace",
//            xcodeprojPath: "/Users/rubanov/Documents/Projects/dodo-mobile-ios/DodoPizza/DodoPizza.xcodeproj",
//            derivedDataPath: "/Users/rubanov/Library/Developer/Xcode/DerivedData",
            projectName: "DodoPizzaTuist",
            xcworkspacePath: "/Users/rubanov/Documents/Projects/dodo-mobile-ios/DodoPizza/DodoPizzaTuist.xcworkspace",
            xcodeprojPath: "/Users/rubanov/Documents/Projects/dodo-mobile-ios/DodoPizza/DodoPizza.xcodeproj",
            derivedDataPath: "/Users/rubanov/Library/Developer/Xcode/DerivedData",
            xcactivitylogPath: "",
            strictProjectName: false)
        
        let logURL = try logFinder.findLatestLogWithLogOptions(logOptions)
        
        let activityLog = try activityLogParser.parseActivityLogInURL(
            logURL,
            redacted: false,
            withoutBuildSpecificInformation: false)
        
        let buildParser = ParserBuildSteps(
            machineName: nil,
            omitWarningsDetails: true,
            omitNotesDetails: true)
        
        let buildSteps = try buildParser.parse(activityLog: activityLog)
       
        for (i, substep) in buildSteps.subSteps.enumerated() {
            print("\(i) \(substep.title), \(substep.duration)")
        }
        
        let dateFormatter = DateFormatter.iso8601Full
        let events = buildSteps.subSteps.map { substep -> Event in
            let startDate = (substep.subSteps
                                .dropFirst(3).first // skip folder creation
                             ?? substep.subSteps[0])
                .startDate
            
            return Event(
                taskName: substep.title.without_Build_target,
                startDate: dateFormatter.date(from: startDate)!,
                endDate: dateFormatter.date(from: substep.endDate)!,
                steps: substep.subSteps
                    .map { substep in
                        Event(taskName: substep.title,
                              startDate: dateFormatter.date(from: substep.startDate)!,
                              endDate: dateFormatter.date(from: substep.endDate)!,
                              steps: [])
                    }
            )
        }.sorted { lhsEvent, rhsEvent in
            lhsEvent.startDate < rhsEvent.startDate
        }
        
        return events
    }
}

extension String {
    // TODO: Add tests
    // 1. "Build target Crypto"
    // 2. "Crypto"
    var without_Build_target: String {
        let prefix = "Build target "
        if self.hasPrefix(prefix) {
            return String(self.suffix(count - prefix.count))
        } else {
            return self
        }
    }
}
