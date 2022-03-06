//
//  MouseContorller.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 06.03.2022.
//

import AppKit

class MouseContorller: NSResponder {
    
    var trackingArea: NSTrackingArea!
    var view: DetailView!
    
    func addMouseTracking(to view: DetailView) {
        self.view = view
        
        trackingArea = NSTrackingArea(
            rect: view.bounds,
            options: [.activeAlways,
                      .mouseMoved,
                      .mouseEnteredAndExited,
                      .inVisibleRect],
            owner: self,
            userInfo: nil)
        view.addTrackingArea(trackingArea)
    }
    
    override func mouseEntered(with event: NSEvent) {
        view.window?.acceptsMouseMovedEvents = true
        view.window?.makeFirstResponder(self)
    }
    
    override func mouseMoved(with event: NSEvent) {
        let coordinate = view.contentView.convert(
            event.locationInWindow,
            from: nil)
        
        highlightEvent(at: coordinate)
    }
    
    override func mouseExited(with event: NSEvent) {
        view.window?.acceptsMouseMovedEvents = false
        
        removeHighlightedEvent()
    }
    
    func highlightEvent(at coordinate: CGPoint) {
        view.modulesLayer?.highlightEvent(at: coordinate)
        view.modulesLayer?.drawConcurrencyLine(at: coordinate)
        view.hudView.hudLayer?.drawTimeline(at: coordinate)
    }
    
    func removeHighlightedEvent() {
        view.modulesLayer?.clearHighlightedEvent()
        view.modulesLayer?.clearConcurrency()
        view.hudView.hudLayer?.clearConcurrency()
    }
}
