//
//  ZoomController.swift
//  BuildDeps
//
//  Created by Mikhail Rubanov on 13.02.2022.
//

import AppKit

protocol ZoomDelegate: AnyObject {
    func didZoom(to magnification: CGFloat)
}

class ZoomController {
    init(scrollView: NSScrollView,
         delegate: ZoomDelegate,
         scaleFactor: CGFloat = NSScreen.main!.backingScaleFactor) {
        self.scrollView = scrollView
        self.screenScaleFactor = scaleFactor
        self.delegate = delegate
    }
    
    let scrollView: NSScrollView
    let screenScaleFactor: CGFloat
    weak var delegate: ZoomDelegate?
    
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
        
        delegate?.didZoom(to: magnification)
    }
    
    private func updateScale(to scale: CGFloat) {
        scrollView.contentView.layer?.updateScale(to: scale)
    }
}
