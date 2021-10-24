//
//  ModulesLayer.swift
//  
//
//  Created by Mikhail Rubanov on 13.10.2021.
//

import QuartzCore
import Interface

class ModulesLayer: CALayer {
    let events: [Event]
    private let rects: [EventRelativeRect]
    private(set) var shapes: [EventLayer]
    
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
}

