//
//  AppLayer.swift
//  
//
//  Created by Mikhail Rubanov on 09.10.2021.
//

import QuartzCore
import AppKit

extension CALayer {
    public func updateWithoutAnimation(_ block: () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        block()
        CATransaction.commit()
    }
}

public class AppLayer: CALayer {
    public let events: [Event]
    
    private let modulesLayer: DependeciesLayer
    private let periodsLayer: PeriodsLayer
    private let concurrencyLayer: ConcurrencyLayer
    
    private let fullframes: [CALayer]
    
    public var showSubtask: Bool = true {
        didSet {
            modulesLayer.showSubtask = showSubtask
        }
    }
    
    public var showLinks: Bool = true {
        didSet {
            modulesLayer.showLinks = showLinks
        }
    }
    
    public var showPerformance: Bool = true {
        didSet {
            periodsLayer.isHidden = !showPerformance
        }
    }
    
    public init(events: [Event], scale: CGFloat) {
        self.events = events
        
        self.modulesLayer = DependeciesLayer(events: events, scale: scale)
        self.concurrencyLayer = ConcurrencyLayer(events: events, scale: scale)
        
        self.periodsLayer = PeriodsLayer(periods: events.allPeriods(),
                                         start: events.start(),
                                         totalDuration: events.duration())
        
        fullframes = [periodsLayer, modulesLayer, concurrencyLayer]
        
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
        
        super.init(layer: layer)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    // MARK: - Actions
    
    public func event(at coordinate: CGPoint) -> Event? {
        modulesLayer.eventLineContains(coordinate: coordinate)
    }
    
    public func eventIndexInLine(coordinate: CGPoint) -> Int? {
        modulesLayer.eventIndexInLine(coordinate: coordinate)
    }
    
    // MARK: Event
    public func highlightEvent(at coordinate: CGPoint) {
        modulesLayer.highlightEvent(at: coordinate)
    }
    
    // MARK: Concurrency
    public func drawConcurrency(at coordinate: CGPoint) {
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
    
        backgroundColor = Colors.backColor()
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

