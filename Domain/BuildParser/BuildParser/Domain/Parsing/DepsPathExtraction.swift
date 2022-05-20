//
//  DepsPathExtraction.swift
//  BuildParser
//
//  Created by Mikhail Rubanov on 29.04.2022.
//

import Foundation
import XCLogParser

struct DepsPathExtraction {
    let rootURL: URL
    
    func depedenciesPath(activityLog: IDEActivityLog) -> URL? {
        guard let fileName = fileName(from: activityLog) else { return nil }
        
        return rootURL.appendingPathComponent("Build")
            .appendingPathComponent("Intermediates.noindex")
            .appendingPathComponent("XCBuildData")
            .appendingPathComponent(fileName)
    }
    
    func fileName(from activityLog: IDEActivityLog) -> String? {
        guard let section = activityLog.mainSection.subSections
            .first?.subSections.first(where: { subsection in
                subsection.title == "Create build description"
            }) else { return nil }
        
        guard let number = number(from: String(section.text)) else { return nil }
        return "\(number)-targetGraph.txt"
    }
    
    func number(from description: String) -> String? {
        let patten = "XCBuildData\\/(\\w*)-"
        let regex = try! NSRegularExpression(pattern: patten)
        let matches = regex.matches(in: description, options: .withoutAnchoringBounds,
                                    range: description.fullRange)
        guard let match = matches.last,
              match.numberOfRanges > 1
        else { return nil }
        
        let rangeInContent = Range(match.range(at: 1),
                                   in: description)!
        
        let text = description[rangeInContent]
        return String(text)
    }
}
