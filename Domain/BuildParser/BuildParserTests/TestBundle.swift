//
//  TestBundle.swift
//  BuildParserTests
//
//  Created by Mikhail Rubanov on 29.04.2022.
//

import Foundation
import Details

class TestBundle {
    var simpleClean: URL {
        try! snapshot(name: "SimpleClean").project.currentActivityLog
    }
    
    func snapshot(name: String) throws -> XcodeBuildSnapshot {
        let url = Bundle(for: TestBundle.self)
            .url(forResource: name,
                 withExtension: "bgbuildsnapshot")!
        
        return try XcodeBuildSnapshot(url: url)
    }
}
