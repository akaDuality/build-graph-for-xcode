//
//  DepsPathExtraction.swift
//  BuildParser
//
//  Created by Mikhail Rubanov on 29.04.2022.
//

import Foundation
import XCLogParser

public enum DepedendencyPath {
    case xcode14_3(URL)
    case xcode15(URL)
}

struct DepsPathExtractionWithVersions {
    let rootURL: URL
    
    func depedenciesPath(activityLog: IDEActivityLog) -> DepedendencyPath? {
        guard let path = DepsPathExtraction()
            .depedenciesPath(activityLog: activityLog)
        else { return nil }
        
        let isFileExists = FileManager.default.fileExists(atPath: path.path)
        
        if isFileExists {
            // Latest version is found
            return .xcode15(path)
        } else if let pathOld = DepsPathExtraction_old(rootURL: rootURL)
            .depedenciesPath(activityLog: activityLog) {
            
            // Fallback to previous version
            return .xcode14_3(pathOld)
        } else {
            return nil
        }
    }
}

/// Xcode 14.3
struct DepsPathExtraction {
    func depedenciesPath(activityLog: IDEActivityLog) -> URL? {
        guard let sectionText = textFromcreateBuildDescription(at: activityLog)
        else { return nil }
        
        let path = path(sectionText: sectionText)
            
        return path
    }
    
    func path(sectionText: String) -> URL? {
        guard let path = NSRegularExpression.firstMatch(in: sectionText,
                                                        pattern: "Build description path: (.+)")
        else { return nil }
        
        return URL(fileURLWithPath: path)
            .appendingPathComponent("target-graph.txt")
    }
    
    func textFromcreateBuildDescription(at activityLog: IDEActivityLog) -> String? {
        guard let section = activityLog
            .mainSection
            .subsection(title: "Prepare build")?
            .subsection(title: "Create build description")
        else { return nil }

        return String(section.text)
    }
}

extension IDEActivityLogSection {
    func subsection(title: String) -> IDEActivityLogSection? {
        subSections
            .first(where: { section in
                section.title == title
            })
    }
}

/// Before Xcode 14.3
struct DepsPathExtraction_old {
    let rootURL: URL
    
    func depedenciesPath(activityLog: IDEActivityLog) -> URL? {
        guard let fileName = fileName(from: activityLog) else { return nil }
        
        return rootURL.appendingPathComponent("Build")
            .appendingPathComponent("Intermediates.noindex")
            .appendingPathComponent("XCBuildData")
            .appendingPathComponent(fileName)
    }
    
    func fileName(from activityLog: IDEActivityLog) -> String? {
        guard let section = activityLog
            .mainSection
            .subsection(title: "Prepare build")?
            .subsection(title: "Create build description")
        else { return nil }
        let sectionText = String(section.text)
        
        guard let number = NSRegularExpression.firstMatch(in: sectionText, pattern: "XCBuildData\\/(\\w*)-")
        else { return nil }
        
        return "\(number)-targetGraph.txt"
    }
    
    func number(from description: String) -> String? {
        return NSRegularExpression.firstMatch(in: description, pattern: "XCBuildData\\/(\\w*)-")
    }
}

extension NSRegularExpression {
    static func firstMatch(in text: String, pattern: String) -> String? {
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: text, options: .withoutAnchoringBounds,
                                    range: text.fullRange)
        guard let match = matches.last,
              match.numberOfRanges > 1
        else { return nil }
        
        let rangeInContent = Range(match.range(at: 1), in: text)!
        
        let text = text[rangeInContent]
        return String(text)
    }
}

