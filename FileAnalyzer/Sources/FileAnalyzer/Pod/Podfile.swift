//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 03.09.2021.
//

import Foundation

typealias Pod = String
typealias PodSet = Set<Pod>

class Podfile {
    init(path: URL, name: String) {
        self.path = path
        self.name = name
        self.pods = Self.readPods(path: path)
    }
    
    let path: URL
    let name: String
    let pods: PodSet!
    var common: PodSet!
    
    static func readPods(path: URL) -> PodSet {
        let podFile = content(for: path)
        let pods = pods(in: podFile)
        return pods
    }
    
    static func pods(in content: String) -> PodSet {
        Set(PodfileReader().read(content: content))
    }
    
    static func content(for file: URL) -> String {
        return try! String(contentsOf: file, encoding: .utf8)
    }
    
    func detectCommon(with all: Set<Pod>) {
        common = all.intersection(pods)
    }
}
