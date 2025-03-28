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

public class InteractionsSettings {
    public static var shared = InteractionsSettings()
    
    public var highlightOnHover: Bool = true
    public var showTime: Bool = true
    public var showBlockingDependeciesWithoutHighlighting: Bool = true
    public var resizeWindowOnProjectSelection: Bool = true
    
    public init() {}
}

public class AppLayer: CALayer {
    public let events: [Event]
//    public let relativeBuildStart: CGFloat
    
    private let modulesLayer: DependeciesLayer
//    private let periodsLayer: PeriodsLayer
    private let concurrencyLayer: ConcurrencyLayer
//    private let buildStartLayer: BuildStartLayer
    
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
//            periodsLayer.isHidden = !showPerformance
        }
    }
    
    public init(events: [Event], relativeBuildStart: CGFloat, fontSize: CGFloat, scale: CGFloat) {
        self.events = events
        
        self.modulesLayer = DependeciesLayer(events: events,
                                             fontSize: fontSize,
                                             scale: scale)
        self.concurrencyLayer = ConcurrencyLayer(events: events, scale: scale)
//        self.buildStartLayer = BuildStartLayer(scale: scale)
//        self.relativeBuildStart = relativeBuildStart
//        buildStartLayer.relativeBuildStart = relativeBuildStart
//        self.periodsLayer = PeriodsLayer(periods: events.allPeriods(),
//                                         start: events.start(),
//                                         totalDuration: events.duration())
        
        fullframes = [
//            periodsLayer,
            modulesLayer,
            concurrencyLayer,
//            buildStartLayer
        ]
        
        // Time Layer
        super.init()
        
        setup(scale: scale)
    }
    
    public override init(layer: Any) {
        let layer = layer as! AppLayer
        
        self.events = layer.events
//        self.relativeBuildStart = layer.relativeBuildStart
        
        self.modulesLayer = layer.modulesLayer
        self.concurrencyLayer = layer.concurrencyLayer
//        self.buildStartLayer = layer.buildStartLayer
//        self.periodsLayer = layer.periodsLayer
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
    public func selectEvent(at coordinate: CGPoint) {
        modulesLayer.selectEvent(at: coordinate)
    }
    
    public func highlightEvent(at coordinate: CGPoint) {
        modulesLayer.highlightEvent(at: coordinate)
    }
    
    public func highlightEvent(with name: String?) {
        guard let name = name else {
            modulesLayer.highlightedEvent = nil
            return
        }
        
        let event = modulesLayer.events.first { event in
            event.taskName.localizedStandardContains(name)
        }
        
        modulesLayer.highlightedEvent = event
    }
    
    // MARK: Concurrency
    public func drawConcurrencyLine(at coordinate: CGPoint) {
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

