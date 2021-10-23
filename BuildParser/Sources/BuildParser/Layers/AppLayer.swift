//
//  AppLayer.swift
//  
//
//  Created by Mikhail Rubanov on 09.10.2021.
//

import QuartzCore
import AppKit
import Interface

extension CALayer {
    public func updateWithoutAnimation(_ block: () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        block()
        CATransaction.commit()
    }
}

public class AppLayer: CALayer {
    let events: [Event]
    
    public var dependencies: [Dependency] = [] {
        didSet {
            modulesLayer.dependencies = dependencies
        }
    }
    
    private let modulesLayer: ModulesLayer
    private let periodsLayer: PeriodsLayer
    private let concurrencyLayer: ConcurrencyLayer
    private let timelineLayer: TimelineLayer
    
    private let fullframes: [CALayer]
    
    public init(events: [Event], scale: CGFloat) {
        self.events = events
        
        self.modulesLayer = ModulesLayer(events: events, scale: scale)
        self.concurrencyLayer = ConcurrencyLayer(events: events, scale: scale)
        
        self.periodsLayer = PeriodsLayer(periods: events.allPeriods(),
                                         start: events.start(),
                                         totalDuration: events.duration())
        self.timelineLayer = TimelineLayer(eventsDuration: events.duration(), scale: scale)
        
        fullframes = [periodsLayer, modulesLayer, concurrencyLayer, timelineLayer]
        
        // Time Layer
        super.init()
        
        setup(scale: scale)
    }
    public override init(layer: Any) {
        let layer = layer as! AppLayer
        
        self.events = layer.events
        self.modulesLayer = layer.modulesLayer
        self.concurrencyLayer = layer.concurrencyLayer
        self.periodsLayer = layer.periodsLayer
        self.fullframes = layer.fullframes
        self.timelineLayer = layer.timelineLayer
        self.dependencies = layer.dependencies
        
        super.init(layer: layer)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    // MARK: - Actions
    // MARK: Event
    public func highlightEvent(at coordinate: CGPoint) {
        modulesLayer.highlightEvent(at: coordinate)
    }
    
    // MARK: Concurrency
    public func drawConcurrency(at coordinate: CGPoint) {
        timelineLayer.coordinate = coordinate
        concurrencyLayer.drawConcurrency(at: coordinate)
    }
    
    public func clearConcurrency() {
        concurrencyLayer.coordinate = nil
    }
    
    public func clearHighlightedEvent() {
        modulesLayer.highlightedEvent = nil
    }
    
    private func setup(scale: CGFloat) {
        for layer in fullframes {
            addSublayer(layer)
        }
    
        backgroundColor = Colors.backColor
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        for layer in fullframes {
            layer.frame = bounds
        }
    }

    public var intrinsicContentSize: CGSize {
        return modulesLayer.intrinsicContentSize
    }
}

