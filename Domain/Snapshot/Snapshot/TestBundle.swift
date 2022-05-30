//
//  TestBundle.swift
//  BuildParserTests
//
//  Created by Mikhail Rubanov on 29.04.2022.
//

import Foundation
import Details

public class TestBundle {
    
    public init() {}
    
    public var simpleClean: XcodeBuildSnapshot {
        try! snapshot(name: "SimpleClean")
    }
    
    public func snapshot(name: String) throws -> XcodeBuildSnapshot {
        let url = Bundle(for: TestBundle.self)
            .url(forResource: name,
                 withExtension: "bgbuildsnapshot")!
        
        return try XcodeBuildSnapshot(url: url)
    }
}
