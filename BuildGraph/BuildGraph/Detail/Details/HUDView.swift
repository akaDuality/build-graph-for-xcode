//
//  HUDView.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 06.03.2022.
//

import Foundation
import AppKit
import BuildParser

class HUDView: FlippedView {
    var hudLayer: HUDLayer?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup(duration: TimeInterval, scale: CGFloat) {
        hudLayer = HUDLayer(duration: duration, scale: scale)
        wantsLayer = true
        layer?.addSublayer(hudLayer!)
    }
    
    override func layout() {
        super.layout()
        
        layer?.updateWithoutAnimation {
            self.hudLayer?.frame = bounds
            self.hudLayer?.layoutIfNeeded()
        }
    }
    
    override func updateLayer() {
        super.updateLayer()
        
        hudLayer?.setNeedsLayout()
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
}
