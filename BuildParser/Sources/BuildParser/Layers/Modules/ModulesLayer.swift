//
//  ModulesLayer.swift
//  
//
//  Created by Mikhail Rubanov on 13.10.2021.
//

import QuartzCore

class ModulesLayer: CALayer {
    
    var showSubtask: Bool = true {
        didSet {
            for shape in shapes {
                shape.showSubtask = showSubtask
            }
        }
    }
    
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
        let event = eventLineContains(coordinate: coordinate)
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
        higlightedLift.backgroundColor = Colors.liftColor()
        self.higlightedLift.frame = .zero
        addSublayer(higlightedLift)
        
        for (_, event) in events.enumerated() {
            let layer = EventLayer(
                event: event,
                scale: scale)
            shapes.append(layer)
            addSublayer(layer)
        }
    }
    
    func eventLineContains(coordinate: CGPoint) -> Event? {
        guard let eventIndexInLine = eventIndexInLine(coordinate: coordinate)
        else { return nil }
        
        return events[eventIndexInLine]
    }
    
    func eventIndexInLine(coordinate: CGPoint) -> Int? {
        for (i, shape) in shapes.enumerated() {
            if shape
                .frame.insetBy(dx: 0, dy: -vSpace/2)
                .inLine(
                    coordinate
                ) {
                return i
            }
        }
        return nil
    }
    
//    func eventFrameContains(coordinate: CGPoint) -> Event? {
//        let index = shapes.firstIndex { shape in
//            shape.frame.contains(coordinate)
//        }
//
//        guard let index = index else { return nil }
//
//        return events[index]
//    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        for (i, shape) in shapes.enumerated() {
            let rect = rects[i]
            let frame = frame(for: i, rect: rect)
            shape.frame = frame 
            
            // TODO: Blockers should be detected by links
//            let event = events[i]
//            if events.isBlocker(event) {
//                shape.backgroundColor = .init(red: 1, green: 0, blue: 0, alpha: 1)
//                    .copy(alpha: alpha(for: rect))
//            } else {
//                shape.backgroundColor = rect.backgroundColor
//                    .copy(alpha: alpha(for: rect))
//            }
            
            shape.opacity = alpha(for: rect)
            
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
        return CGSize(width: 5000,
                      height: CGFloat(rects.count) * (height + vSpace) + PeriodsLayer.periodsHeight + 100)
    }
    
    var height: CGFloat = 14
    let vSpace: CGFloat = 1
    
    private func alpha(for rect: EventRelativeRect) -> Float {
        // TODO: Draw all connections
        if let highlightedEvent = highlightedEvent {
            if rect.event.domain == highlightedEvent.domain
                || highlightedEvent.parentsContains(rect.event.taskName) {
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

