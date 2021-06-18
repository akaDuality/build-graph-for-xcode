//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 17.06.2021.
//

import Foundation

import OctoKit

class LeadTime {
    public func fetchLeadTime(tag: String,
                            then completion: @escaping (_ response: Result<Double, Error>) -> Void) {
        
    }
    
    
    init(owner: String, name: String, token: String) {
        self.owner = owner
        self.name = name
        self.config = TokenConfiguration(token)
    }
    
    private let owner: String
    private let name: String
    private let config: TokenConfiguration
}
