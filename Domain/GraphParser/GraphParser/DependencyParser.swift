//
//  DependencyParser.swift
//  
//
//  Created by Mikhail Rubanov on 23.10.2021.
//

import Foundation

public class DependencyParser {
    
    public init() {}
    
    public func parse(path: URL) -> [Dependency]? {
        guard let depsContent = try? String(contentsOf: path) else {
            return nil
        }
        
        return parseFile(depsContent)
    }
    
    public func parseFile(_ input: String) -> [Dependency] {
        let strings = input.components(separatedBy: "\n")
            .dropFirst() // No need in "Target dependency graph ..."
       
        let deps = deps(Array(strings))
            .compactMap(dependency(from:))
        return deps
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
        
        guard indices.count > 0 else { return [] }
        
        result.append(Array(strings[indices.last!...(strings.count - 1)]))
        
        return result
    }
    
    func parse(_ input: String) -> Dependency? {
        let strings = input.components(separatedBy: "\n")
        
        return dependency(from: strings)
    }
    
    private func dependency(from strings: [String]) -> Dependency? {
        var deps: [Target] = []
        if strings[0].hasSuffix(", depends on:") {
            deps = strings.dropFirst().map(parseTarget(_:))
        }
        
        let target = parseTarget(strings[0])
        
        guard !deps.hasRecursiveDependencies(to: target) else {
            return nil
        }
                
        return Dependency(
            target: target,
            dependencies: deps)
    }
    
    func parseTarget(_ input: String) -> Target {
        let regex = try! NSRegularExpression(
            pattern: "(\\w*-?\\w*) in (\\w*-?\\w*)"
        )
        
        let matche = regex
            .matches(in: input,
                     options: [],
                     range: input.fullRange)
            .first!
        
        return Target(target: matche.range(at: 1, in: input),
                      project: matche.range(at: 2, in: input))
    }
}

extension NSTextCheckingResult {
    func range(at index: Int, in content: String) -> String {
        let rangeInContent = Range(range(at: index),
                                   in: content)!
        
        return String(content[rangeInContent])
    }
}

extension Array where Element == Target {
    func hasRecursiveDependencies(to target: Element) -> Bool {
        contains(where: { depTarget in
            return depTarget.target == target.target
        })
    }
}

extension String {
    var fullRange: NSRange {
        return NSRange(location: 0, length: count)
    }
}
