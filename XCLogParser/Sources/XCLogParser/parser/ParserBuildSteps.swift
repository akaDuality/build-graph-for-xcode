// Copyright (c) 2019 Spotify AB.
//
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation
import os
import CoreAudio

/// Parses the .xcactivitylog into a tree of `BuildStep`
// swiftlint:disable type_body_length
public final class ParserBuildSteps {

    let machineName: String
    var buildIdentifier = ""
    var buildStatus = ""
    var currentIndex = 0
    var totalErrors = 0
    var totalWarnings = 0
    var targetErrors = 0
    var targetWarnings = 0
    let swiftCompilerParser = SwiftCompilerParser()
    let clangCompilerParser = ClangCompilerParser()

    /// If true, the details of Warnings won't be added.
    /// Useful to save space.
    let omitWarningsDetails: Bool

    /// If true, the Notes won't be parsed.
    /// Usefult to save space.
    let omitNotesDetails: Bool

    lazy var warningCountRegexp: NSRegularExpression? = {
        let pattern = "([0-9]) warning[s]? generated"
        return NSRegularExpression.fromPattern(pattern)
    }()

    lazy var schemeRegexp: NSRegularExpression? = {
        let pattern = "scheme (.*)"
        return NSRegularExpression.fromPattern(pattern)
    }()

    lazy var targetRegexp: NSRegularExpression? = {
        let pattern = "BUILD( AGGREGATE)? TARGET (.*?) OF PROJECT"
        return NSRegularExpression.fromPattern(pattern)
    }()

    lazy var clangArchRegexp: NSRegularExpression? = {
        let pattern = "normal (\\w+) objective-c"
        return NSRegularExpression.fromPattern(pattern)
    }()

    lazy var swiftcArchRegexp: NSRegularExpression? = {
        let pattern = "^CompileSwift normal (\\w*) "
        return NSRegularExpression.fromPattern(pattern)
    }()
    
    let logger: OSLog?

    /// - parameter machineName: The name of the machine. It will be used to create a unique identifier
    /// for the log. If `nil`, the host name will be used instead.
    /// - parameter omitWarningsDetails: if true, the Warnings won't be parsed
    /// - parameter omitNotesDetails: if true, the Notes won't be parsed
    public init(machineName: String? = nil,
                omitWarningsDetails: Bool,
                omitNotesDetails: Bool) {
        if let machineName = machineName {
            self.machineName = machineName
        } else {
            self.machineName = MacOSMachineNameReader().machineName ?? "unknown"
        }
        self.omitWarningsDetails = omitWarningsDetails
        self.omitNotesDetails = omitNotesDetails
        
        if #available(macOS 10.14, *) {
            logger = OSLog(subsystem: "ParserBuildSteps", category: OSLog.Category.pointsOfInterest)
        } else {
            logger = nil
        }
    }

    /// Parses the content from an Xcode log into a `BuildStep`
    /// - parameter activityLog: An `IDEActivityLog`
    /// - returns: A `BuildStep` with the parsed content from the log.
    public func parse(activityLog: IDEActivityLog) throws -> BuildStep {
        self.buildIdentifier = "\(machineName)_\(activityLog.mainSection.uniqueIdentifier)"
        buildStatus = activityLog.mainSection.localizedResultString.replacingOccurrences(of: "Build ", with: "")
        let mainSectionWithTargets = activityLog.mainSection.groupedByTarget()
        var mainBuildStep = try parseLogSection(logSection: mainSectionWithTargets, type: .main, parentSection: nil)
//        mainBuildStep.errorCount = totalErrors
//        mainBuildStep.warningCount = totalWarnings
        mainBuildStep = decorateWithSwiftcTimes(mainBuildStep)
        return mainBuildStep
    }
    
    private var deep = 0
    // swiftlint:disable function_body_length cyclomatic_complexity
    public func parseLogSection(logSection: IDEActivityLogSection,
                                type: BuildStepType,
                                parentSection: BuildStep?,
                                parentLogSection: IDEActivityLogSection? = nil)
        throws -> BuildStep {
            currentIndex += 1
            
            let title = logSection.title.string
            
            let signpost = false
            if signpost {
                if #available(macOS 10.14, *) {
                    os_signpost(.begin, log: logger!, name: "section", "%@", title)
                }
            }
            let signature = logSection.signature.string
            
            let detailType = type == .detail ? DetailStepType.getDetailType(signature: signature) : .none
//            var schema = ""
//            var parentIdentifier = ""
//            if type == .main {
//                schema = getSchema(title: title)
//            } else if let parentSection = parentSection {
//                schema = parentSection.schema
//                parentIdentifier = parentSection.identifier
//            }
//            if type == .target {
//                targetErrors = 0
//                targetWarnings = 0
//            }
//            let notices = parseWarningsAndErrorsFromLogSection(logSection, forType: detailType)
//            let warnings: [Notice]? = notices?["warnings"]
//            let errors: [Notice]? = notices?["errors"]
//            let notes: [Notice]? = notices?["notes"]
//            var errorCount: Int = 0, warningCount: Int = 0
//            if let errors = errors {
//                errorCount = errors.count
//                totalErrors += errors.count
//                targetErrors += errors.count
//            }
//            if let warnings = warnings {
//                warningCount = warnings.count
//                totalWarnings += warnings.count
//                targetWarnings += warnings.count
//            }
            var step = BuildStep(type: type,
//                                 machineName: machineName,
//                                 buildIdentifier: self.buildIdentifier,
//                                 identifier: "\(self.buildIdentifier)_\(currentIndex)",
//                                 parentIdentifier: parentIdentifier,
//                                 domain: logSection.domainType.string,
                                 title: type == .target ? getTargetName(title) : title,
                                 signature: signature,
                                 startDate: toDate(timeInterval: logSection.timeStartedRecording),
//                                 endDate: toDate(timeInterval: logSection.timeStoppedRecording),
//                                 startTimestamp: toTimestampSince1970(timeInterval: logSection.timeStartedRecording),
//                                 endTimestamp: toTimestampSince1970(timeInterval: logSection.timeStoppedRecording),
                                 duration: getDuration(startTimeInterval: logSection.timeStartedRecording,
                                                       endTimeInterval: logSection.timeStoppedRecording),
                                 detailStepType: detailType,
//                                 buildStatus: buildStatus,
//                                 schema: schema,
                                 subSteps: [BuildStep](),
//                                 warningCount: warningCount,
//                                 errorCount: errorCount,
//                                 architecture: parseArchitectureFromLogSection(logSection, andType: detailType),
//                                 documentURL: logSection.location.documentURLString.string,
//                                 warnings: omitWarningsDetails ? [] : warnings,
//                                 errors: errors,
//                                 notes: omitNotesDetails ? [] : notes,
//                                 swiftFunctionTimes: nil,
                                 fetchedFromCache: wasFetchedFromCache(parent: parentSection, section: logSection),
                                 compilationEndTimestamp: 0,
                                 compilationDuration: 0
//                                 clangTimeTraceFile: nil,
//                                 linkerStatistics: nil,
//                                 swiftTypeCheckTimes: nil
                                 )

            
            step.subSteps = try logSection.subSections.map { subSection -> BuildStep in
//                let duration = getDuration(startTimeInterval: subSection.timeStartedRecording,
//                                           endTimeInterval: subSection.timeStoppedRecording)
//                guard duration > 0.001 else { return nil }
                
                let subType: BuildStepType = type == .main ? .target : .detail
                return try parseLogSection(logSection: subSection,
                                           type: subType,
                                           parentSection: step,
                                           parentLogSection: logSection)
            }
            
//            if type == .target {
//                step.warningCount = targetWarnings
//                step.errorCount = targetErrors
//            } else if type == .detail {
//                step = step.moveSwiftStepsToRoot()
//            }
//            if step.detailStepType == .swiftCompilation {
//                if step.fetchedFromCache == false {
//                    swiftCompilerParser.addLogSection(logSection)
//                }
//                if let swiftSteps = logSection.getSwiftIndividualSteps(buildStep: step,
//                                                                       parentCommandDetailDesc:
//                                                                       parentLogSection?.commandDetailDesc.string ?? "",
//                                                                       currentIndex: &currentIndex) {
//                    step.subSteps.append(contentsOf: swiftSteps)
//                    step = step.withFilteredNotices()
//                }
//            }

//            if step.fetchedFromCache == false && step.detailStepType == .cCompilation {
//                step.clangTimeTraceFile = "file://\(clangCompilerParser.parseTimeTraceFile(logSection) ?? "")"
//            }

//            if step.fetchedFromCache == false && step.detailStepType == .linker {
//                step.linkerStatistics = clangCompilerParser.parseLinkerStatistics(logSection)
//            }

//            step = addCompilationTimes(step: step)
            
            if signpost {
                if #available(macOS 10.14, *) {
                    os_signpost(.end, log: logger!, name: "section")
                }
            }
            return step
    }

    private func toDate(timeInterval: Double) -> Date {
        return Date(timeIntervalSinceReferenceDate: timeInterval)
    }

    private func toTimestampSince1970(timeInterval: Double) -> Double {
        return Date(timeIntervalSinceReferenceDate: timeInterval).timeIntervalSince1970
    }

    private func getDuration(startTimeInterval: Double, endTimeInterval: Double) -> Double {
        var duration = endTimeInterval - startTimeInterval
        // If the endtime is almost the same as the endtime, we got a constant
        // in the tokens and a date in the future (year 4001). Here we normalize it to 0.0 secs
        if endTimeInterval >= 63113904000.0 {
            duration = 0.0
        }
        duration = duration >= 0 ? duration : 0.0
        return duration
    }

    private func getSchema(title: String) -> String {
        let schema = title.replacingOccurrences(of: "Build ", with: "")
        guard let schemaRegexp = schemeRegexp else {
            return schema
        }
        let range = NSRange(location: 0, length: title.count)
        let matches = schemaRegexp.matches(in: title, options: .reportCompletion, range: range)
        guard let match = matches.first else {
            return schema
        }
        return title.substring(match.range(at: 1))
    }

    private func toBuildStep(domainType: Int8) -> BuildStepType {
        switch domainType {
        case 0:
            return .main
        case 1:
            return .target
        case 2:
            return .detail
        default:
            return .detail
        }
    }

    /// In CLI logs, the target name is enclosed in a string like
    /// === BUILD TARGET TargetName OF PROJECT ProjectName WITH CONFIGURATION config ===
    /// This function extracts the target name of it.
    private func getTargetName(_ text: String) -> String {
        guard let targetRegexp = targetRegexp else {
            return text
        }
        let range = NSRange(location: 0, length: text.count)
        let matches = targetRegexp.matches(in: text, options: .reportCompletion, range: range)
        guard let match = matches.first, match.numberOfRanges == 3 else {
            return text
        }
        return "Target \(text.substring(match.range(at: 2)))"
    }

    private func parseArchitectureFromLogSection(_ logSection: IDEActivityLogSection,
                                                 andType type: DetailStepType) -> String {
        guard let clangArchRegexp = clangArchRegexp, let swiftcArchRegexp = swiftcArchRegexp else {
            return ""
        }
        switch type {
        case .cCompilation:
            return parseArchitectureFromCommand(command: logSection.signature.string, regexp: clangArchRegexp)
        case .swiftCompilation:
            return parseArchitectureFromCommand(command: logSection.signature.string, regexp: swiftcArchRegexp)
        default:
            return ""
        }
    }

    private func parseArchitectureFromCommand(command: String, regexp: NSRegularExpression) -> String {
        let range = NSRange(location: 0, length: command.count)
        let matches = regexp.matches(in: command, options: .reportCompletion, range: range)
        guard let match = matches.first else {
            return ""
        }
        return command.substring(match.range(at: 1))
    }

    private func parseWarningsAndErrorsFromLogSection(_ logSection: IDEActivityLogSection, forType type: DetailStepType)
        -> [String: [Notice]]? {
        let notices = Notice.parseFromLogSection(logSection, forType: type)
        return ["warnings": notices.getWarnings(),
                "errors": notices.getErrors(),
                "notes": notices.getNotes()]
    }

    private func decorateWithSwiftcTimes(_ mainStep: BuildStep) -> BuildStep {
        swiftCompilerParser.parse()
        guard swiftCompilerParser.hasFunctionTimes() || swiftCompilerParser.hasTypeChecks() else {
            return mainStep
        }
        var mutableMainStep = mainStep
        mutableMainStep.subSteps = mainStep.subSteps.map { subStep -> BuildStep in
            var mutableTargetStep = subStep
            mutableTargetStep.subSteps = addSwiftcTimesSteps(mutableTargetStep.subSteps)
            return mutableTargetStep
        }
        return mutableMainStep
    }

    private func addSwiftcTimesSteps(_ subSteps: [BuildStep]) -> [BuildStep] {
        return []
//        return subSteps.map { subStep -> BuildStep in
//            switch subStep.detailStepType {
//            case .swiftCompilation:
//                var mutableSubStep = subStep
//                if swiftCompilerParser.hasFunctionTimes() {
//                    mutableSubStep.swiftFunctionTimes = swiftCompilerParser.findFunctionTimesForFilePath(
//                    subStep.documentURL)
//                }
//                if swiftCompilerParser.hasTypeChecks() {
//                    mutableSubStep.swiftTypeCheckTimes =
//                        swiftCompilerParser.findTypeChecksForFilePath(subStep.documentURL)
//                }
//                if mutableSubStep.subSteps.count > 0 {
//                     mutableSubStep.subSteps = addSwiftcTimesSteps(subStep.subSteps)
//                }
//                return mutableSubStep
//            case .swiftAggregatedCompilation:
//                var mutableSubStep = subStep
//                mutableSubStep.subSteps = addSwiftcTimesSteps(subStep.subSteps)
//                return mutableSubStep
//            default:
//                return subStep
//            }
//        }
    }

    private func wasFetchedFromCache(parent: BuildStep?, section: IDEActivityLogSection) -> Bool {
        if section.wasFetchedFromCache {
            return section.wasFetchedFromCache
        }
        return parent?.fetchedFromCache ?? false
    }

//    func addCompilationTimes(step: BuildStep) -> BuildStep {
//        switch step.type {
//        case .detail:
//            return step.with(newCompilationEndTimestamp: step.endTimestamp,
//                             andCompilationDuration: step.duration)
//        case .target:
//            return addCompilationTimesToTarget(step)
//        case .main:
//            return addCompilationTimesToApp(step)
//        }
//    }
//
//    private func addCompilationTimesToTarget(_ target: BuildStep) -> BuildStep {
//
//        let lastCompilationStep = target.subSteps
//            .filter { $0.isCompilationStep() && $0.fetchedFromCache == false }
//            .max { $0.compilationEndTimestamp < $1.compilationEndTimestamp }
//        guard let lastStep = lastCompilationStep else {
//            return target.with(newCompilationEndTimestamp: target.startTimestamp, andCompilationDuration: 0.0)
//        }
//        return target.with(newCompilationEndTimestamp: lastStep.compilationEndTimestamp,
//                         andCompilationDuration: lastStep.compilationEndTimestamp - target.startTimestamp)
//    }
//
//    private func addCompilationTimesToApp(_ app: BuildStep) -> BuildStep {
//        let lastCompilationStep = app.subSteps
//            .filter { $0.compilationDuration > 0 && $0.fetchedFromCache == false }
//            .max { $0.compilationEndTimestamp < $1.compilationEndTimestamp }
//        guard let lastStep = lastCompilationStep else {
//            return app.with(newCompilationEndTimestamp: app.startTimestamp,
//                            andCompilationDuration: 0.0)
//        }
//        return app.with(newCompilationEndTimestamp: lastStep.compilationEndTimestamp,
//                         andCompilationDuration: lastStep.compilationEndTimestamp - app.startTimestamp)
//    }

}

extension Substring {
    var string: String {
        String(self)
    }
}
