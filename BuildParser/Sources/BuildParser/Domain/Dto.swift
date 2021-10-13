//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 11.10.2021.
//

import Foundation

struct EventsDTO: Decodable {
    let events: [EventDTO]
}

struct EventDTO: Decodable {
    let date: Date
    let taskName: String
    let event: EventType
}

enum EventType: String, Decodable {
    case start
    case end
}
