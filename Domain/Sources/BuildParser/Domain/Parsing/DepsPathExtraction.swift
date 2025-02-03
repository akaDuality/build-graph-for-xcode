//
//  DepsPathExtraction.swift
//  BuildParser
//
//  Created by Mikhail Rubanov on 29.04.2022.
//

import Foundation
import XCLogParser

public struct DependencyPath {
    
    public let url: URL
    public let type: FileType
    
    public enum FileType {
    case xcode14_3
    case xcode15
    }
    

}

struct DepsPathExtractionWithVersions {
    let rootURL: URL
    
    func depedenciesPath(activityLog: IDEActivityLog) -> DependencyPath? {
        path_xcode15(activityLog: activityLog)
        ?? path_xcode14(activityLog: activityLog)
    }
    
    func path_xcode15(activityLog: IDEActivityLog) -> DependencyPath? {
        guard let path = DepsPathExtraction().depedenciesPath(activityLog: activityLog) else {
            print("No path to dependency Xcode 15 in activityLog")
            return nil
        }
        
        // Replace
        // file:///Users/mikhail/Library/Developer/Xcode/DerivedData/BulidGraph-bzryakxofvjibdffbqmtzvinmpdk/Build/Intermediates.noindex/XCBuildData/584b872b7e96316afd6ba1f3a3c43f43.xcbuilddata/target-graph.txt
        // to
        // file:///Users/mikhail/Library/Developer/Xcode/DerivedData/BulidGraph-bzryakxofvjibdffbqmtzvinmpdk/Build/Products/Debug/BuildParserTests.xctest/Contents/Resources/Domain_Snapshot.bundle/Contents/Resources/Xcode14.3.bgbuildsnapshot/Build/Intermediates.noindex/XCBuildData/584b872b7e96316afd6ba1f3a3c43f43.xcbuilddata/target-graph.txt
        
        
        guard let content = try? String(contentsOf: path) else {
            return nil
        }
        let containsArrows = content.contains { character in
            character == "➜"
        }
        
        
        return DependencyPath(url: path, type: containsArrows ? .xcode15: .xcode14_3)
    }
    
    func path_xcode14(activityLog: IDEActivityLog) -> DependencyPath? {
        guard let path = DepsPathExtraction_old(rootURL: rootURL).depedenciesPath(activityLog: activityLog) else {
            print("No path to dependency Xcode 14 in activityLog")
            return nil
        }
        
        guard let content = try? String(contentsOf: path) else {
            return nil
        }
        let containsArrows = content.contains { character in
            character == "➜"
        }
        
        
        return DependencyPath(url: path, type: containsArrows ? .xcode15: .xcode14_3)
    }
}

/// Xcode 15
struct DepsPathExtraction {
    func depedenciesPath(activityLog: IDEActivityLog) -> URL? {
        guard let sectionText = textFromCreateBuildDescription(at: activityLog)
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
    
    func textFromCreateBuildDescription(at activityLog: IDEActivityLog) -> String? {
        guard let section = activityLog
            .mainSection
            .subsection(title: "Prepare build")?
            .subsection(title: "Create build description")
        else {
            print("Can't find \"Create build description\" subsection")
            return nil
        }

        let text = String(section.text)
        
        #if DEBUG
        if text.isEmpty {
            activityLog.printRecursiveDescription()
        }
        #endif
        
        return text
    }
    
    // TODO: Prepare build contains subSections with "Compute target dependency graph" messages. We can extract this data directly from activityLog
}

extension IDEActivityLog {
    func printRecursiveDescription() {
        for section in mainSection.subSections {
            section.printRecursiveDescription()
        }
    }
}

extension IDEActivityLogSection {
    func printRecursiveDescription(inset: String? = nil) {
        for section in subSections {
            if let inset {
                print("\(inset)\(section.title)")
                section.printRecursiveDescription(inset: inset + "\t")
            } else {
                print("\t\(section.title)")
                section.printRecursiveDescription(inset: "\t")
            }
            
        }
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
        
        guard let number = number(from: sectionText)
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

