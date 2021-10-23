//
//  DependencyParser.swift
//  
//
//  Created by Mikhail Rubanov on 23.10.2021.
//

import Foundation
import Interface

public class DependencyParser {
    
    public init() {}
    
    public func parseFile(_ input: String) -> [Dependency] {
        let strings = input.components(separatedBy: "\n")
            .dropFirst() // No need in "Target dependency graph ..."
        
        return deps(Array(strings))
            .map(dependency(from:))
    }
    
    func deps(_ strings: [String]) -> [[String]] {
        var indices = [Int]()
        for (index, string) in strings.enumerated() {
            let startOfDependencies = string.contains(", ")
            if startOfDependencies {
                indices.append(index)
            }
        }
        
        var result = [[String]]()
        for (i, index) in indices.dropLast().enumerated() {
            let nextIndex = indices[i + 1]
            let range = index..<nextIndex
            let depsDescription = strings[range]
            result.append(Array(depsDescription))
        }
        
        result.append(Array(strings[indices.last!...(strings.count - 1)]))
        
        return result
    }
    
    func parse(_ input: String) -> Dependency {
        let strings = input.components(separatedBy: "\n")
        
        return dependency(from: strings)
    }
    
    private func dependency(from strings: [String]) -> Dependency {
        var deps: [Target] = []
        if strings[0].hasSuffix(", depends on:") {
            deps = strings.dropFirst().map(parseTarget(_:))
        }
        
        return Dependency(
            target: parseTarget(strings[0]),
            dependencies: deps)
    }
    
    func parseTarget(_ input: String) -> Target {
        let regex = try! NSRegularExpression(
            pattern: "(\\w*) in (\\w*)")
        
        let matche = regex
            .matches(in: input,
                     options: [],
                     range: input.fullRange)
            .first!
        
        
        return Target(target: matche.xx(at: 1, in: input),
                      project: matche.xx(at: 2, in: input))
    }
}

extension NSTextCheckingResult {
    func xx(at index: Int, in content: String) -> String {
        let rangeInContent = Range(range(at: index),
                                   in: content)!
        
        return String(content[rangeInContent])
    }
}

extension String {
    var fullRange: NSRange {
        return NSRange(location: 0, length: count)
    }
}
