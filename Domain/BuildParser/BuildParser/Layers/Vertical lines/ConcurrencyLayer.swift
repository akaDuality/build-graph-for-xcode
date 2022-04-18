//
//  ConcurrencyLayer.swift
//  
//
//  Created by Mikhail Rubanov on 13.10.2021.
//

import QuartzCore

class ConcurrencyLayer: VerticalLineLayer {
    
    private let events: [Event]
    
    public init(events: [Event], scale: CGFloat) {
        self.events = events
        
        super.init(scale: scale)
        
        self.color = Colors.concurencyColor()
    }
    
    public override init(layer: Any) {
        let layer = layer as! ConcurrencyLayer
        
        self.events = layer.events
        
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawConcurrency(at coordinate: CGPoint) {
        self.coordinate = coordinate
        updateLayoutWithoutAnimation()
        
        let relativeX = coordinate.x / frame.width
        let time = events.duration() * relativeX
        let concurency = events.concurrency(at: time)
        concurrencyTitle.string = "\(concurency)"
    }
}
