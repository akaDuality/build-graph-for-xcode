//
//  ZoomController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 13.02.2022.
//

import AppKit

class ZoomController {
    init(scrollView: NSScrollView,
         scaleFactor: CGFloat = NSScreen.main!.backingScaleFactor) {
        self.scrollView = scrollView
        self.screenScaleFactor = scaleFactor
    }
    
    let scrollView: NSScrollView
    let screenScaleFactor: CGFloat
    
    func zoomIn() {
        zoom(to: magnification + magnificationStep)
    }
    
    func zoomOut() {
        zoom(to: magnification - magnificationStep)
    }
    
    var magnificationStep: CGFloat {
        if magnification <= 1 {
            return 0.25
        } else {
            return 0.5
        }
    }
    
    var magnification: CGFloat {
        scrollView.magnification
    }
    
    var center: NSPoint {
        NSPoint(x: scrollView.bounds.midX,
                y: scrollView.bounds.midY)
    }
    
    private func zoom(to magnification: CGFloat) {
        scrollView.setMagnification(magnification,
                                    centeredAt: center)
        updateScale(to: magnification * screenScaleFactor)
    }
    
    private func updateScale(to scale: CGFloat) {
        scrollView.contentView.layer?.updateScale(to: scale)
    }
}
