//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 08.11.2021.
//

import AppKit

extension NSAppearanceCustomization {
    @discardableResult
    public func performWithEffectiveAppearanceAsDrawingAppearance<T>(
        _ block: () -> T) -> T {
            // Similar to `NSAppearance.performAsCurrentDrawingAppearance`, but
            // works below macOS 11 and assigns to `result` properly
            // (capturing `result` inside a block doesn't work the way we need).
            let result: T
            let old = NSAppearance.current
            NSAppearance.current = self.effectiveAppearance
            result = block()
            NSAppearance.current = old
            return result
        }
}

extension NSColor {
    /// Uses the `NSApplication.effectiveAppearance`.
    /// If you need per-view accurate appearance, prefer this instead:
    ///
    ///     let cgColor = aView.performWithEffectiveAppearanceAsDrawingAppearance { aColor.cgColor }
    public var effectiveCGColor: CGColor {
#if DEBUG
        let isTesting = NSClassFromString("XCTest")  != nil
        if isTesting {
            return cgColor
        }
#endif
        return NSApp.performWithEffectiveAppearanceAsDrawingAppearance {
            self.cgColor
        }
    }
}
