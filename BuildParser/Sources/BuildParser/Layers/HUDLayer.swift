//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 02.01.2022.
//

import QuartzCore
import Interface

public class HUDLayer: CALayer {
    private let timelineLayer: TimelineLayer
    
    public init(events: [Event], scale: CGFloat) {
        self.timelineLayer = TimelineLayer(eventsDuration: events.duration(), scale: scale)
        
        // Time Layer
        super.init()
        
        addSublayer(timelineLayer)
    }
    
    public override init(layer: Any) {
        let layer = layer as! HUDLayer
        
        self.timelineLayer = layer.timelineLayer
        
        super.init(layer: layer)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        timelineLayer.frame = bounds
    }
    
    public func drawConcurrency(at coordinate: CGPoint) {
        timelineLayer.coordinate = coordinate
    }
    
    public func clearConcurrency() {
        timelineLayer.coordinate = nil
    }
}
