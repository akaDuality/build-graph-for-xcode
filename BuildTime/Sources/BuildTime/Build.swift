//
//  Build.swift
//  
//
//  Created by Mikhail Rubanov on 28.10.2021.
//

import Foundation

struct Build: Equatable {
    let userName: String
    
    let date: String
    let duration: Int
    let result: Result
    let workspace: String
    let project: String
    let xcode: Xcode?
    
    struct Xcode: Equatable {
        let version: String
        let build: String
    }
    
    enum Result: String, Equatable {
        case success
        case fail
    }
}
