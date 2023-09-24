//
//  DependencyParser.swift
//  
//
//  Created by Mikhail Rubanov on 23.10.2021.
//

import Foundation

public class DependencyParser15 {
    
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
       
        let deps = dependenciesChunks(Array(strings))
            .compactMap(dependency(from:))
        return deps
    }
    
    func dependenciesChunks(_ strings: [String]) -> [[String]] {
        var chunkStartIndexes = [Int]()
        for (index, string) in strings.enumerated() {
            let startOfDependenciesChunk = !string.contains("➜ ")
            if startOfDependenciesChunk {
                chunkStartIndexes.append(index)
            }
        }
        
        var result = [[String]]()
        for (i, chunkStart) in chunkStartIndexes
            .dropLast() // will increment index
            .enumerated()
        {
            let nextIndex = chunkStartIndexes[i + 1]
            let range = chunkStart..<nextIndex
            let depsDescription = strings[range]
            result.append(Array(depsDescription))
        }
        
        guard chunkStartIndexes.count > 0 else { return [] }
        
        result.append(Array(strings[chunkStartIndexes.last!...(strings.count - 1)]))
        
        return result
    }
    
    func dependency(from strings: [String]) -> Dependency? {
        var deps: [Target] = []
        if strings.count > 1 {
            deps = strings.dropFirst().map(parseTarget(_:))
        }
        
        let target = parseTarget(strings[0])
        
//        guard !deps.hasRecursiveDependencies(to: target) else {
//            return nil
//        }
                
        return Dependency(
            target: target,
            dependencies: deps)
    }
    
    func parseTarget(_ input: String) -> Target {
        if let match = targetInProjectRegex.firstMatch(in: input) {
            return Target(target: match.range(at: 1, in: input),
                          project: match.range(at: 2, in: input))
        } else if let match = targetInModuleRegex.firstMatch(in: input) {
            return Target(target: match.range(at: 1, in: input),
                          project: match.range(at: 2, in: input))
        } else if let match = targetInModuleRegexWithoutBraces.firstMatch(in: input) {
            return Target(target: match.range(at: 1, in: input),
                          project: match.range(at: 2, in: input))
        } else {
            fatalError()
        }
    }
    
    let libName = "(\\w*[-?\\w]*)"
    
    lazy var targetInProjectRegex = try! NSRegularExpression(
        pattern: "\\'\(libName)\\' in project \\'\(libName)\\'"
    )
    
    lazy var targetInModuleRegex = try! NSRegularExpression(
        pattern: "\\'\(libName)\\' in \\'\(libName)\\'"
    )
    
    lazy var targetInModuleRegexWithoutBraces = try! NSRegularExpression(
        pattern: "\(libName) in \(libName)"
    )
}

extension NSRegularExpression {
    func firstMatch(in input: String) -> NSTextCheckingResult? {
        matches(in: input, range: input.fullRange).first
    }
}
