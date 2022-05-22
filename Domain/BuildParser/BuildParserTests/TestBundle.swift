//
//  TestBundle.swift
//  BuildParserTests
//
//  Created by Mikhail Rubanov on 29.04.2022.
//

import Foundation
import Details

class TestBundle {
    var simpleClean: XcodeBuildSnapshot {
        try! snapshot(name: "SimpleClean")
    }
    
    func snapshot(name: String) throws -> XcodeBuildSnapshot {
        let url = Bundle(for: TestBundle.self)
            .url(forResource: name,
                 withExtension: "bgbuildsnapshot")!
        
        return try XcodeBuildSnapshot(url: url)
    }
}
