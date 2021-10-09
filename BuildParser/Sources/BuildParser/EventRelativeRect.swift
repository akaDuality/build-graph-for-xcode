//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import Foundation
import UIKit

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
    
    var backgroundColor: UIColor {
        switch event.type {
        case .framework:
            return .lightGray
        case .helpers:
            return .red.withAlphaComponent(0.5)
        case .tests:
            return .blue.withAlphaComponent(0.5)
        }
    }
}
