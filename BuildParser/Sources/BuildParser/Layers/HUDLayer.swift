//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 02.01.2022.
//

import QuartzCore

public class HUDLayer: CALayer {
    private var timelineLayer: TimelineLayer
    private let legendLayer: ColorsLegendLayer
    
    private let eventsDuration: TimeInterval
    
    public init(duration: TimeInterval, scale: CGFloat) {
        self.eventsDuration = duration
        self.timelineLayer = TimelineLayer(eventsDuration: duration, scale: scale)
        self.legendLayer = ColorsLegendLayer(scale: scale)
        
        // Time Layer
        super.init()
        
        addSublayer(timelineLayer)
        addSublayer(legendLayer)
    }
    
    public func scale(to magnification: CGFloat) {
        timelineLayer.removeFromSuperlayer()
        
        let newDuration = eventsDuration / magnification
        
        self.timelineLayer = TimelineLayer(eventsDuration: newDuration, scale: contentsScale)
        addSublayer(timelineLayer)
        self.setNeedsLayout()
    }
    
    public override init(layer: Any) {
        let layer = layer as! HUDLayer
        
        self.timelineLayer = layer.timelineLayer
        self.legendLayer = layer.legendLayer
        self.eventsDuration = layer.eventsDuration
        
        super.init(layer: layer)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        timelineLayer.frame = bounds
        
        let height: CGFloat = legendLayer.intrinsicContentSize.height
        legendLayer.frame = CGRect(x: 20,
                                   y: frame.height - height - 60,
                                   width: legendLayer.intrinsicContentSize.width,
                                   height: height)
    }
    
    public func drawTimeline(at coordinate: CGPoint) {
        timelineLayer.coordinate = coordinate
    }
    
    public func clearConcurrency() {
        timelineLayer.coordinate = nil
    }
}
