//
//  ModulesLayer.swift
//  
//
//  Created by Mikhail Rubanov on 13.10.2021.
//

import QuartzCore
import AppKit
import Interface

class ModulesLayer: CALayer {
    private let events: [Event]
    private let rects: [EventRelativeRect]
    private(set) var shapes: [EventLayer]
    
    var dependencies: [Dependency] = [
        Dependency(
            target: Target(target: "DUIKit", project: "DUIKit"),
            dependencies: [
                Target(target: "Stories", project: "Stories"),
                Target(target: "Rate", project: "Rate"),
                Target(target: "Phone", project: "Phone"),
                Target(target: "Payment", project: "Payment"),
            ])
    ]
    
    public var highlightedEvent: Event? = nil {
        didSet {
            guard highlightedEvent != oldValue else {
                return // skip redraw of modules, nothing changed
            }
            
            updateWithoutAnimation {
                setNeedsLayout()
                layoutIfNeeded()
            }
            
            higlightedLift.opacity = (highlightedEvent != nil) ? 1: 0
        }
    }
    
    private let higlightedLift: CALayer
    
    public func highlightEvent(at coordinate: CGPoint) {
        let event = event(at: coordinate)
        highlightedEvent = event
    }
    
    public init(events: [Event], scale: CGFloat) {
        self.events = events
        
        self.rects = events.map { event in
            EventRelativeRect(event: event,
                              absoluteStart: events.start(),
                              totalDuration: events.duration())
        }
        self.shapes = .init()
        self.higlightedLift = .init()
        
        super.init()
        
        setup(scale: scale)
    }
    
    public override init(layer: Any) {
        let layer = layer as! ModulesLayer
        
        self.events = layer.events
        self.shapes = layer.shapes
        self.highlightedEvent = layer.highlightedEvent
        self.rects = layer.rects
        self.higlightedLift = layer.higlightedLift
        
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(scale: CGFloat) {
        higlightedLift.backgroundColor = Colors.liftColor
        self.higlightedLift.frame = .zero
        addSublayer(higlightedLift)
        
        for (i, event) in events.enumerated() {
            let layer = EventLayer(
                text: event.taskName,
                isLast: i == events.count)
            layer.contentsScale = scale
            shapes.append(layer)
            addSublayer(layer)
        }
    }
    
    private func event(at coordinate: CGPoint) -> Event? {
        for (i, shape) in shapes.enumerated() {
            if shape
                .frame.insetBy(dx: 0, dy: -vSpace/2)
                .inLine(
                    coordinate
                ) {
                return events[i]
            }
        }
        return nil
    }
    
    lazy var criticalDependenciesLayer: CAShapeLayer = {
        let bezierLayer = CAShapeLayer()
        bezierLayer.strokeColor = Colors.criticalDependencyColor
        bezierLayer.fillColor = NSColor.clear.cgColor
        bezierLayer.lineWidth = 1
        addSublayer(bezierLayer)
        
        return bezierLayer
    }()
    
    lazy var regularDependenciesLayer: CAShapeLayer = {
        let bezierLayer = CAShapeLayer()
        bezierLayer.strokeColor = Colors.regularDependencyColor
        bezierLayer.fillColor = NSColor.clear.cgColor
        bezierLayer.lineWidth = 1
        addSublayer(bezierLayer)
        
         return bezierLayer
    }()
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        for (i, shape) in shapes.enumerated() {
            let rect = rects[i]
            let frame = frame(for: i, rect: rect)
            shape.frame = frame
            
            let event = events[i]
            if events.isBlocker(event) {
                shape.backgroundColor = .init(red: 1, green: 0, blue: 0, alpha: 1)
                    .copy(alpha: alpha(for: rect))
            } else {
                shape.backgroundColor = rect.backgroundColor
                    .copy(alpha: alpha(for: rect))
            }
            
            if rect.event.taskName == highlightedEvent?.taskName {
                higlightedLift.frame = CGRect(x: frame.minX,
                                              y: 0, width: frame.width,
                                              height: self.frame.height)
            }
        }
        
        drawConnections(for: highlightedEvent)
    }
    
    func drawConnections(for event: Event?) {
        regularPath = CGMutablePath()
        criticalPath = CGMutablePath()
        
        for dependency in dependencies {
            guard let fromIndex = events.index(name: dependency.target.target)
            else { continue }
            
            for target in dependency.dependencies {
                
                let isHighlightedModule = target.target == event?.taskName
                || dependency.target.target == event?.taskName
                
                guard let toIndex = events.index(name: target.target)
                else { continue }
                
                connectModules(
                    from: shapes[toIndex],
                    to: shapes[fromIndex],
                    on: regularPath,
                    isHighlightedModule: isHighlightedModule
                )
            }
        }
        
        regularDependenciesLayer.frame = bounds
        regularDependenciesLayer.path = regularPath
        
        criticalDependenciesLayer.frame = bounds
        criticalDependenciesLayer.path = criticalPath
    }
    
    var regularPath = CGMutablePath()
    var criticalPath = CGMutablePath()
    
    func connect(
        from: CGPoint,
        to: CGPoint,
        on path: CGMutablePath) {
        let offset: CGFloat = 75
        path.move(to: from)
        path.addCurve(to: to,
                      control1: from.offset(x: offset, y: 0),
                      control2: to.offset(x: -offset, y: 0),
                      transform: .identity)
    }
    
    func connectModules(
        from: CALayer,
        to: CALayer,
        on path: CGMutablePath,
        isHighlightedModule: Bool) {
        
        let isBlockerDependency = (to.frame.minX - from.frame.maxX) / bounds.width < 0.01
        guard (isBlockerDependency && highlightedEvent == nil)
        || isHighlightedModule else {
            return
        }
        
        connect(from: from.frame.rightCenter,
                to: to.frame.leftCenter,
                on: isBlockerDependency ? criticalPath : regularPath)
    }
    
    private func frame(for i: Int, rect: EventRelativeRect) -> CGRect {
        let width = self.frame.width
        let startY = PeriodsLayer.periodsHeight * 1.5
        
        return CGRect(x: width * rect.start,
                      y: startY + CGFloat(i) * (self.height + vSpace),
                      width: width * rect.duration,
                      height: self.height)
    }
    
    public var intrinsicContentSize: CGSize {
        return CGSize(width: 2400,
                      height: CGFloat(rects.count) * (height + vSpace) + PeriodsLayer.periodsHeight)
    }
    
    var height: CGFloat = 14
    let vSpace: CGFloat = 1
    

    private func alpha(for rect: EventRelativeRect) -> CGFloat {
        if let highlightedEvent = highlightedEvent {
            if rect.event.domain == highlightedEvent.domain {
                return 1
            } else {
                return Colors.dimmingAlpha
            }
        } else {
            return 1
        }
    }
}

extension CGRect {
    func inLine(_ coordinate: CGPoint) -> Bool {
        (minY...maxY).contains(coordinate.y)
    }
    
    var rightCenter: CGPoint {
        CGPoint(x: maxX, y: midY)
    }
    
    var bottomCenter: CGPoint {
        CGPoint(x: midX, y: maxY)
    }
    
    var leftCenter: CGPoint {
        CGPoint(x: minX, y: midY)
    }
}

extension CGPoint {
    func offset(x: CGFloat, y: CGFloat) -> CGPoint {
        CGPoint(x: self.x + x,
                y: self.y + y)
    }
}

extension Array where Element == Event {
    public func index(name: String) -> Int? {
        firstIndex { event in
            event.taskName == name
        }
    }
}
