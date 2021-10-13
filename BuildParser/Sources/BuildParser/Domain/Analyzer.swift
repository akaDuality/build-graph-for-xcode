//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 09.10.2021.
//

import Foundation

class Analyzer {
    func analyze(events: [Event]) {
        let testHelpers = events.filter("TestHelpers")
        printType(testHelpers, name: "TestHelpers")
        
        let units = events.filter("Unit-Tests")
        printType(units, name: "Unit-Tests")
        
        let other = events.filter { event in
            !(units.contains(event) || testHelpers.contains(event))
        }
        
        printType(other, name: "Other")
    }
    
    func printType(_ events: [Event], name: String) {
        //        printTime(events)
        printSummaryTime(events, name: name)
    }
    
    func printTime(_ events: [Event]) {
        for event in events {
            print("\(event.duration) \(event.taskName)")
        }
    }
    
    func printSummaryTime(_ events: [Event], name: String) {
        let sum = events.map { $0.duration }.reduce(0, +)
        print("sum \(sum), \(name)")
    }
}
