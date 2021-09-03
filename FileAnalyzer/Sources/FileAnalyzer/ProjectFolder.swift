//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 03.09.2021.
//

import Foundation

public struct ProjectFolder {
    let projectsFolder: URL = "/Users/rubanov/Documents/Projects/"
    
    public var pizza: URL {
        projectsFolder.appendingPathComponent("dodo-mobile-ios/DodoPizza/")
    }
    
    public var doner: URL {
        projectsFolder.appendingPathComponent("doner-mobile-ios/")
    }
    
    public var drinkit: URL {
        projectsFolder.appendingPathComponent("drinkit-mobile-ios")
    }
}

extension URL {
    var podfile: URL {
        appendingPathComponent("Podfile")
    }
}

extension URL: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self = URL(fileURLWithPath: value)
    }
}
