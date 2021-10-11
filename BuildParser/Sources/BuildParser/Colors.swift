//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import CoreGraphics

struct Colors {
    static let textColor: CGColor = .init(gray: 0, alpha: 1)
    static let backColor: CGColor = .init(gray: 0.3, alpha: 1)
    static let liftColor: CGColor = .init(gray: 1, alpha: 0.05)
}

extension EventRelativeRect {
    var backgroundColor: CGColor {
        switch event.type {
        case .framework:
            return .init(gray: 0.7, alpha: 1)
        case .helpers:
            return .init(red: 1, green: 0, blue: 0, alpha: 0.5)
        case .tests:
            return .init(red: 0, green: 0, blue: 1, alpha: 0.5)
        }
    }
}
