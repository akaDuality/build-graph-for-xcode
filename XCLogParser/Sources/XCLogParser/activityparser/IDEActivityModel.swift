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

// swiftlint:disable file_length
public class IDEActivityLog {
    public let version: Int8
    public let mainSection: IDEActivityLogSection

    public init(version: Int8, mainSection: IDEActivityLogSection) {
        self.version = version
        self.mainSection = mainSection
    }
}

public class IDEActivityLogSection {
    public let sectionType: Int8
    public let domainType: Substring
    public let title: Substring
    public let signature: Substring
    public let timeStartedRecording: Double
    public var timeStoppedRecording: Double
    public var subSections: [IDEActivityLogSection]
    public let text: Substring
    public let messages: [IDEActivityLogMessage]
    public let wasCancelled: Bool
    public let isQuiet: Bool
    public var wasFetchedFromCache: Bool
    public let subtitle: Substring
    public let location: DVTDocumentLocation
    public let commandDetailDesc: Substring
    public let uniqueIdentifier: Substring
    public let localizedResultString: Substring
    public let xcbuildSignature: Substring
    public let unknown: Int

    public init(sectionType: Int8,
                domainType: Substring,
                title: Substring,
                signature: Substring,
                timeStartedRecording: Double,
                timeStoppedRecording: Double,
                subSections: [IDEActivityLogSection],
                text: Substring,
                messages: [IDEActivityLogMessage],
                wasCancelled: Bool,
                isQuiet: Bool,
                wasFetchedFromCache: Bool,
                subtitle: Substring,
                location: DVTDocumentLocation,
                commandDetailDesc: Substring,
                uniqueIdentifier: Substring,
                localizedResultString: Substring,
                xcbuildSignature: Substring,
                unknown: Int) {
        self.sectionType = sectionType
        self.domainType = domainType
        self.title = title
        self.signature = signature
        self.timeStartedRecording = timeStartedRecording
        self.timeStoppedRecording = timeStoppedRecording
        self.subSections = subSections
        self.text = text
        self.messages = messages
        self.wasCancelled = wasCancelled
        self.isQuiet = isQuiet
        self.wasFetchedFromCache = wasFetchedFromCache
        self.subtitle = subtitle
        self.location = location
        self.commandDetailDesc = commandDetailDesc
        self.uniqueIdentifier = uniqueIdentifier
        self.localizedResultString = localizedResultString
        self.xcbuildSignature = xcbuildSignature
        self.unknown = unknown
    }

}

public class IDEActivityLogUnitTestSection: IDEActivityLogSection {
    public let testsPassedString: Substring
    public let durationString: Substring
    public let summaryString: Substring
    public let suiteName: Substring
    public let testName: Substring
    public let performanceTestOutputString: Substring

    public init(sectionType: Int8,
                domainType: Substring,
                title: Substring,
                signature: Substring,
                timeStartedRecording: Double,
                timeStoppedRecording: Double,
                subSections: [IDEActivityLogSection],
                text: Substring,
                messages: [IDEActivityLogMessage],
                wasCancelled: Bool,
                isQuiet: Bool,
                wasFetchedFromCache: Bool,
                subtitle: Substring,
                location: DVTDocumentLocation,
                commandDetailDesc: Substring,
                uniqueIdentifier: Substring,
                localizedResultString: Substring,
                xcbuildSignature: Substring,
                unknown: Int,
                testsPassedString: Substring,
                durationString: Substring,
                summaryString: Substring,
                suiteName: Substring,
                testName: Substring,
                performanceTestOutputString: Substring
                ) {
        self.testsPassedString = testsPassedString
        self.durationString = durationString
        self.summaryString = summaryString
        self.suiteName = suiteName
        self.testName = testName
        self.performanceTestOutputString = performanceTestOutputString
        super.init(sectionType: sectionType,
                   domainType: domainType,
                   title: title,
                   signature: signature,
                   timeStartedRecording: timeStartedRecording,
                   timeStoppedRecording: timeStoppedRecording,
                   subSections: subSections,
                   text: text,
                   messages: messages,
                   wasCancelled: wasCancelled,
                   isQuiet: isQuiet,
                   wasFetchedFromCache: wasFetchedFromCache,
                   subtitle: subtitle,
                   location: location,
                   commandDetailDesc: commandDetailDesc,
                   uniqueIdentifier: uniqueIdentifier,
                   localizedResultString: localizedResultString,
                   xcbuildSignature: xcbuildSignature,
                   unknown: unknown)
    }
}

public class IDEActivityLogMessage {
    public let title: Substring
    public let shortTitle: Substring
    public let timeEmitted: Double
    public let rangeEndInSectionText: UInt64
    public let rangeStartInSectionText: UInt64
    public let subMessages: [IDEActivityLogMessage]
    public let severity: Int
    public let type: Substring
    public let location: DVTDocumentLocation
    public let categoryIdent: Substring
    public let secondaryLocations: [DVTDocumentLocation]
    public let additionalDescription: Substring

    public init(title: Substring,
                shortTitle: Substring,
                timeEmitted: Double,
                rangeEndInSectionText: UInt64,
                rangeStartInSectionText: UInt64,
                subMessages: [IDEActivityLogMessage],
                severity: Int,
                type: Substring,
                location: DVTDocumentLocation,
                categoryIdent: Substring,
                secondaryLocations: [DVTDocumentLocation],
                additionalDescription: Substring) {
        self.title = title
        self.shortTitle = shortTitle
        self.timeEmitted = timeEmitted
        self.rangeEndInSectionText = rangeEndInSectionText
        self.rangeStartInSectionText = rangeStartInSectionText
        self.subMessages = subMessages
        self.severity = severity
        self.type = type
        self.location = location
        self.categoryIdent = categoryIdent
        self.secondaryLocations = secondaryLocations
        self.additionalDescription = additionalDescription
    }
}

public class IDEActivityLogAnalyzerResultMessage: IDEActivityLogMessage {

    public let resultType: Substring
    public let keyEventIndex: UInt64

    public init(title: Substring,
                shortTitle: Substring,
                timeEmitted: Double,
                rangeEndInSectionText: UInt64,
                rangeStartInSectionText: UInt64,
                subMessages: [IDEActivityLogMessage],
                severity: Int,
                type: Substring,
                location: DVTDocumentLocation,
                categoryIdent: Substring,
                secondaryLocations: [DVTDocumentLocation],
                additionalDescription: Substring,
                resultType: Substring,
                keyEventIndex: UInt64) {

        self.resultType = resultType
        self.keyEventIndex = keyEventIndex

        super.init(title: title,
                   shortTitle: shortTitle,
                   timeEmitted: timeEmitted,
                   rangeEndInSectionText: rangeEndInSectionText,
                   rangeStartInSectionText: rangeStartInSectionText,
                   subMessages: subMessages,
                   severity: severity,
                   type: type,
                   location: location,
                   categoryIdent: categoryIdent,
                   secondaryLocations: secondaryLocations,
                   additionalDescription: additionalDescription)
    }
}

public class IDEActivityLogAnalyzerControlFlowStepMessage: IDEActivityLogMessage {

    public let parentIndex: UInt64
    public let endLocation: DVTDocumentLocation
    public let edges: [IDEActivityLogAnalyzerControlFlowStepEdge]

    public init(title: Substring,
                shortTitle: Substring,
                timeEmitted: Double,
                rangeEndInSectionText: UInt64,
                rangeStartInSectionText: UInt64,
                subMessages: [IDEActivityLogMessage],
                severity: Int,
                type: Substring,
                location: DVTDocumentLocation,
                categoryIdent: Substring,
                secondaryLocations: [DVTDocumentLocation],
                additionalDescription: Substring,
                parentIndex: UInt64,
                endLocation: DVTDocumentLocation,
                edges: [IDEActivityLogAnalyzerControlFlowStepEdge]) {

        self.parentIndex = parentIndex
        self.endLocation = endLocation
        self.edges = edges

        super.init(title: title,
                   shortTitle: shortTitle,
                   timeEmitted: timeEmitted,
                   rangeEndInSectionText: rangeEndInSectionText,
                   rangeStartInSectionText: rangeStartInSectionText,
                   subMessages: subMessages,
                   severity: severity,
                   type: type,
                   location: location,
                   categoryIdent: categoryIdent,
                   secondaryLocations: secondaryLocations,
                   additionalDescription: additionalDescription)
    }
}

public class DVTDocumentLocation {
    public let documentURLString: Substring
    public let timestamp: Double

    public init(documentURLString: Substring, timestamp: Double) {
        self.documentURLString = documentURLString
        self.timestamp = timestamp
    }

}

public class DVTMemberDocumentLocation: DVTDocumentLocation {
    public let some: Substring // Sample: irs-zY-n9e
    
    public init(documentURLString: Substring, timestamp: Double, some: Substring) {
        self.some = some
        
        super.init(documentURLString: documentURLString,
                   timestamp: timestamp)
    }
}

public class DVTTextDocumentLocation: DVTDocumentLocation {
    public let startingLineNumber: UInt64
    public let startingColumnNumber: UInt64
    public let endingLineNumber: UInt64
    public let endingColumnNumber: UInt64
    public let characterRangeEnd: UInt64
    public let characterRangeStart: UInt64
    public let locationEncoding: UInt64

    public init(documentURLString: Substring,
                timestamp: Double,
                startingLineNumber: UInt64,
                startingColumnNumber: UInt64,
                endingLineNumber: UInt64,
                endingColumnNumber: UInt64,
                characterRangeEnd: UInt64,
                characterRangeStart: UInt64,
                locationEncoding: UInt64) {
        self.startingLineNumber = startingLineNumber
        self.startingColumnNumber = startingColumnNumber
        self.endingLineNumber = endingLineNumber
        self.endingColumnNumber = endingColumnNumber
        self.characterRangeEnd = characterRangeEnd
        self.characterRangeStart = characterRangeStart
        self.locationEncoding = locationEncoding
        super.init(documentURLString: documentURLString, timestamp: timestamp)
    }
}

public class IDEConsoleItem {
    public let adaptorType: UInt64
    public let content: Substring
    public let kind: UInt64
    public let timestamp: Double

    public init(adaptorType: UInt64, content: Substring, kind: UInt64, timestamp: Double) {
        self.adaptorType = adaptorType
        self.content = content
        self.kind = kind
        self.timestamp = timestamp
    }
}

public class DBGConsoleLog: IDEActivityLogSection {
    public let logConsoleItems: [IDEConsoleItem]

    public init(sectionType: Int8,
                domainType: Substring,
                title: Substring,
                signature: Substring,
                timeStartedRecording: Double,
                timeStoppedRecording: Double,
                subSections: [IDEActivityLogSection],
                text: Substring,
                messages: [IDEActivityLogMessage],
                wasCancelled: Bool,
                isQuiet: Bool,
                wasFetchedFromCache: Bool,
                subtitle: Substring,
                location: DVTDocumentLocation,
                commandDetailDesc: Substring,
                uniqueIdentifier: Substring,
                localizedResultString: Substring,
                xcbuildSignature: Substring,
                unknown: Int,
                logConsoleItems: [IDEConsoleItem]) {
        self.logConsoleItems = logConsoleItems
        super.init(sectionType: sectionType,
                   domainType: domainType,
                   title: title,
                   signature: signature,
                   timeStartedRecording: timeStartedRecording,
                   timeStoppedRecording: timeStoppedRecording,
                   subSections: subSections,
                   text: text,
                   messages: messages,
                   wasCancelled: wasCancelled,
                   isQuiet: isQuiet,
                   wasFetchedFromCache: wasFetchedFromCache,
                   subtitle: subtitle,
                   location: location,
                   commandDetailDesc: commandDetailDesc,
                   uniqueIdentifier: uniqueIdentifier,
                   localizedResultString: localizedResultString,
                   xcbuildSignature: xcbuildSignature,
                   unknown: unknown)
    }
}

public class IDEActivityLogAnalyzerControlFlowStepEdge {
    public let startLocation: DVTDocumentLocation
    public let endLocation: DVTDocumentLocation

    public init(startLocation: DVTDocumentLocation, endLocation: DVTDocumentLocation) {
        self.startLocation = startLocation
        self.endLocation = endLocation
    }
}

public class IDEActivityLogAnalyzerEventStepMessage: IDEActivityLogMessage {

    public let parentIndex: UInt64
    public let description: Substring
    public let callDepth: UInt64

    public init(title: Substring,
                shortTitle: Substring,
                timeEmitted: Double,
                rangeEndInSectionText: UInt64,
                rangeStartInSectionText: UInt64,
                subMessages: [IDEActivityLogMessage],
                severity: Int,
                type: Substring,
                location: DVTDocumentLocation,
                categoryIdent: Substring,
                secondaryLocations: [DVTDocumentLocation],
                additionalDescription: Substring,
                parentIndex: UInt64,
                description: Substring,
                callDepth: UInt64) {

        self.parentIndex = parentIndex
        self.description = description
        self.callDepth = callDepth

        super.init(title: title,
                   shortTitle: shortTitle,
                   timeEmitted: timeEmitted,
                   rangeEndInSectionText: rangeEndInSectionText,
                   rangeStartInSectionText: rangeStartInSectionText,
                   subMessages: subMessages,
                   severity: severity,
                   type: type,
                   location: location,
                   categoryIdent: categoryIdent,
                   secondaryLocations: secondaryLocations,
                   additionalDescription: additionalDescription)
    }
}

// MARK: IDEInterfaceBuilderKit

public class IBMemberID {
    public let memberIdentifier: Substring

    public init(memberIdentifier: Substring) {
        self.memberIdentifier = memberIdentifier
    }
}

public class IBAttributeSearchLocation {
    public let offsetFromStart: UInt64
    public let offsetFromEnd: UInt64
    public let keyPath: Substring

    public init(offsetFromStart: UInt64, offsetFromEnd: UInt64, keyPath: Substring) {
        self.offsetFromEnd = offsetFromEnd
        self.offsetFromStart = offsetFromStart
        self.keyPath = keyPath
    }
}

public class IBDocumentMemberLocation: DVTDocumentLocation {
    public let memberIdentifier: IBMemberID
    public let attributeSearchLocation: IBAttributeSearchLocation?

    public init(documentURLString: Substring,
                timestamp: Double,
                memberIdentifier: IBMemberID,
                attributeSearchLocation: IBAttributeSearchLocation?) {
        self.memberIdentifier = memberIdentifier
        self.attributeSearchLocation = attributeSearchLocation
        super.init(documentURLString: documentURLString, timestamp: timestamp)
    }
}
