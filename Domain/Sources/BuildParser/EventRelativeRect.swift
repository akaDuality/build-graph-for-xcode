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
        precondition(totalDuration != 0)
        
        self.event = event
        self.text = event.description
        self.start = relativeStart(absoluteStart: absoluteStart,
                                   start: event.startDate,
                                   duration: totalDuration)
        self.duration = relativeDuration(start: event.startDate,
                                         end: event.endDate,
                                         duration: totalDuration)
    }
}
