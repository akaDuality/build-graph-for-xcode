//
//  XCTest+Extensions.swift
//  ProjectsTests
//
//  Created by Danila Ferentz on 18.06.22.
//

import XCTest

public extension XCTest {
    
    @discardableResult
    func name(_ value: String) -> XCTest {
        XCTContext.runActivity(named: value, block: { _ in })
        return self
    }
}
