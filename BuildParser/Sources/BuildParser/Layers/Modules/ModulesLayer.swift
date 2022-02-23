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
            for shape in eventShapes {
                shape.showSubtask = showSubtask
            }
        }
    }
    
    let events: [Event]
    private let rects: [EventRelativeRect]
    private(set) var eventShapes: [EventLayer]
    
    var highlightedEvent: Event? = nil {
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
    
    var selectedEvents: [Event] {
        didSet {
            guard selectedEvents != oldValue else {
                return // skip redraw of modules, nothing changed
            }

            updateWithoutAnimation {
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    
    private let higlightedLift: CALayer
    
    public func selectEvent(at coordinate: CGPoint) {
        guard let event = eventLineContains(coordinate: coordinate) else { return }
        
        if let indexToRemove = selectedEvents.firstIndex(of: event) {
            selectedEvents.remove(at: indexToRemove)
        } else {
            selectedEvents.append(event)
        }
    }
    
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
        self.eventShapes = .init()
        self.higlightedLift = .init()
        self.selectedEvents = []
        
        super.init()
        
        setup(scale: scale)
    }
    
    public override init(layer: Any) {
        let layer = layer as! ModulesLayer
        
        self.events = layer.events
        self.eventShapes = layer.eventShapes
        self.highlightedEvent = layer.highlightedEvent
        self.rects = layer.rects
        self.higlightedLift = layer.higlightedLift
        self.selectedEvents = layer.selectedEvents
        
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
            eventShapes.append(layer)
            addSublayer(layer)
        }
    }
    
    func eventLineContains(coordinate: CGPoint) -> Event? {
        guard let eventIndexInLine = eventIndexInLine(coordinate: coordinate)
        else { return nil }
        
        return events[eventIndexInLine]
    }
    
    func eventIndexInLine(coordinate: CGPoint) -> Int? {
        for (i, shape) in eventShapes.enumerated() {
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
        
        for (i, event) in eventShapes.enumerated() {
            let rect = rects[i]
            let frame = frame(for: i, rect: rect)
            event.frame = frame
            event.layoutText(
                spaceToLeft: frame.minX,
                spaceToRight: self.frame.width - frame.maxX)
            
            // TODO: Blockers should be detected by links
//            let event = events[i]
//            if events.isBlocker(event) {
//                shape.backgroundColor = .init(red: 1, green: 0, blue: 0, alpha: 1)
//                    .copy(alpha: alpha(for: rect))
//            } else {
//                shape.backgroundColor = rect.backgroundColor
//                    .copy(alpha: alpha(for: rect))
//            }
            
            event.opacity = alpha(for: rect)
            
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
        var hasSelected = false
        
        if !selectedEvents.isEmpty {
            hasSelected = true
            
            for event in selectedEvents {
                let shouldBeHighlighted = shouldBeHighlighted(event: event,
                                                              domain: rect.event.domain,
                                                              taskName: rect.event.taskName)
                if shouldBeHighlighted {
                    return 1
                }
            }
        }
        
        // TODO: Draw all connections
        if let highlightedEvent = highlightedEvent {
            hasSelected = true
            
            let shouldBeHighlighted = shouldBeHighlighted(event: highlightedEvent,
                                                          domain: rect.event.domain,
                                                          taskName: rect.event.taskName)
            if shouldBeHighlighted {
                return 1
            }
        }
        
        return hasSelected ? Colors.dimmingAlpha : 1
    }
    
    private func shouldBeHighlighted(event: Event, domain: String, taskName: String) -> Bool {
        return domain == event.domain
            || event.parentsContains(taskName)
    }
}

extension CGRect {
    func inLine(_ coordinate: CGPoint) -> Bool {
        (minY...maxY).contains(coordinate.y)
    }
}

