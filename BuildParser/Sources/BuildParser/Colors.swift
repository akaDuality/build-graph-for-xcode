//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import CoreGraphics
import AppKit

struct Colors {
    static let textColor: CGColor = NSColor.labelColor.cgColor
    static let backColor: CGColor = NSColor.textBackgroundColor.cgColor
    static let liftColor: CGColor = NSColor.systemGray.withAlphaComponent(0.05).cgColor
    static let concurencyColor: CGColor = NSColor.systemRed.cgColor
    static let dimmingAlpha: CGFloat = 0.25
    static let timeColor: CGColor = NSColor.tertiaryLabelColor.cgColor
    
    static let criticalDependencyColor = NSColor.systemRed.cgColor
    static let regularDependencyColor = NSColor.secondaryLabelColor.cgColor
    
    static let clear = NSColor.clear.cgColor
}

extension EventRelativeRect {
    var backgroundColor: CGColor {
        switch event.type {
        case .framework:
            if isPod(name: event.taskName) {
                return .init(gray: 0.3, alpha: 1)
            } else {
                return .init(gray: 0.7, alpha: 1)
            }
        case .helpers:
            return .init(red: 1, green: 0, blue: 0, alpha: 0.5)
        case .tests:
            return .init(red: 0, green: 0, blue: 1, alpha: 0.5)
        }
    }
}

func isPod(name: String) -> Bool {
    if name.hasPrefix("Firebase") {
        return true
    }
    
    if name.hasPrefix("Google") {
        return true
    }
    
    if pods.contains(name) {
        return true
    }
    
    return false
}
let pods: [String] = [
"nanopb",
"libPhoneNumber-iOS",
"SwCrypt",
"PromisesObjC",
"PinLayout",
"Nuke",
"MBProgressHUD",
"MARoundButton",
"KeychainSwift",
"KVOController",
"DeviceKit",
"CocoaAsyncSocket",
"HCaptcha-HCaptcha",
"BRYXBanner",
"Bagel"
]
