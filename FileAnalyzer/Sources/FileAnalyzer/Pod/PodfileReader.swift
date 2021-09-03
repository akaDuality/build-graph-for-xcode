//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 03.09.2021.
//

import Foundation

class PodfileReader {
    func read(content: String) -> [String] {
        let regex = try! NSRegularExpression(
            pattern: "pod '(\\w+[\\/|-]?\\w+?)'")
        
        let matches = regex.matches(in: content,
                                    options: [],
                                    range: content.fullRange)
        let pods = matches.map { match -> String in
            let rangeInContent = Range(match.range(at: 1), // get value from capture group (\\w+)
                                       in: content)!
            
            let text = content[rangeInContent]
            return String(text)
        }
        
        return pods
    }
}

extension String {
    var fullRange: NSRange {
        return NSRange(location: 0, length: count)
    }
}
