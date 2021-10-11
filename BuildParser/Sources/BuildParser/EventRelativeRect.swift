//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import CoreGraphics
import Foundation

struct EventRelativeRect {
    let event: Event
    
    let text: String
    let start: CGFloat
    let duration: CGFloat
    
    init(event: Event, absoluteStart: Date, totalDuration: TimeInterval) {
        self.event = event
        self.text = "\(event.taskName), \(event.duration)"
        self.start = CGFloat(event.startDate.timeIntervalSince(absoluteStart) / totalDuration)
        self.duration = CGFloat(event.duration / totalDuration)
    }
}
