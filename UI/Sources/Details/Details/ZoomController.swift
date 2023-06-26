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
    
    func observeScrollChange() {
        scrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didScrollContent),
                                               name: NSView.boundsDidChangeNotification,
                                               object: nil)
    }
    
    @objc func didScrollContent() {
        delegate?.didZoom(to: magnification)
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
