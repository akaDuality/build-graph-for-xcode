//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 10.10.2021.
//

import CoreGraphics
import AppKit
import Interface

struct Colors {
    static var textColor: () -> CGColor = { NSColor.labelColor.effectiveCGColor }
    static var textOverModuleColor: () -> CGColor = { NSColor.black.effectiveCGColor }
    static var textInvertedColor: () -> CGColor = { NSColor.labelColor.effectiveCGColor }
    static var backColor: () -> CGColor = { NSColor.clear.effectiveCGColor }
    static var subtaskColor: () -> CGColor = {NSColor.systemBlue.effectiveCGColor }
    
    static var liftColor: () -> CGColor = { NSColor.systemGray.withAlphaComponent(0.05).effectiveCGColor }
    static var concurencyColor: () -> CGColor = { NSColor.systemRed.effectiveCGColor }
    static var timeColor: () -> CGColor = { NSColor.tertiaryLabelColor.effectiveCGColor }
    
    static var criticalDependencyColor: () -> CGColor = { NSColor.systemRed.effectiveCGColor }
    static var regularDependencyColor: () -> CGColor = { NSColor.systemGreen.effectiveCGColor }
    
    static var clear: () -> CGColor = { NSColor.clear.effectiveCGColor }
    
    static var dimmingAlpha: Float = 0.25
}

extension Event {
    var backgroundColor: CGColor {
        if parents.count == 0 {
            return NSColor.systemGray.effectiveCGColor // Nothing to improve
        }
        
        let defaultColor: NSColor = .systemOrange
        return defaultColor.effectiveCGColor// .init(gray: 0.7, alpha: 1)
        
//        switch event.type {
//        case .framework:
//            if isPod(name: event.taskName) {
//                return .init(gray: 0.3, alpha: 1)
//            } else {
//                return .init(gray: 0.7, alpha: 1)
//            }
//        case .helpers:
//            return .init(red: 1, green: 0, blue: 0, alpha: 0.5)
//        case .tests:
//            return .init(red: 0, green: 0, blue: 1, alpha: 0.5)
//        }
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
