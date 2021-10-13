//
//  ModulesLayer.swift
//  
//
//  Created by Mikhail Rubanov on 13.10.2021.
//

import QuartzCore

class ModulesLayer: CALayer {
    private let events: [Event]
    private let rects: [EventRelativeRect]
    private(set) var shapes: [CALayer]
    private(set) var texts: [CATextLayer]
    
    public var highlightedEvent: Event? = nil {
        didSet {
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
        self.texts = .init()
        self.higlightedLift = .init()
        
        super.init()
        
        setup(scale: scale)
    }
    
    public override init(layer: Any) {
        let layer = layer as! ModulesLayer
        
        self.events = layer.events
        self.shapes = layer.shapes
        self.texts = layer.texts
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
        
        for _ in rects {
            let layer = CALayer()
            layer.contentsScale = scale
            shapes.append(layer)
            addSublayer(layer)
            
            let textLayer = CATextLayer()
            textLayer.contentsScale = scale
            texts.append(textLayer)
            self.addSublayer(textLayer)
        }
    }
    
    private func event(at coorditate: CGPoint) -> Event? {
        for (i, shape) in shapes.enumerated() {
            if shape
                .frame.insetBy(dx: 0, dy: -space/2)
                .inLine(
                    coorditate
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
            
            drawText(rect: rect, i: i, frame: frame)
            
            if rect.event.taskName == highlightedEvent?.taskName {
                higlightedLift.frame = CGRect(x: frame.minX,
                                              y: 0, width: frame.width,
                                              height: self.frame.height)
            }
        }
    }
    
    private func frame(for i: Int, rect: EventRelativeRect) -> CGRect {
        let width = self.frame.width
        
        return CGRect(x: width * rect.start,
                      y: CGFloat(i) * (self.height + space),
                      width: width * rect.duration,
                      height: self.height)
    }
    
    private func drawText(rect: EventRelativeRect, i: Int, frame: CGRect) {
        let text = texts[i]
        text.string = rect.text
        text.frame = CGRect(x: frame.maxX + 2,
                            y: frame.minY + 1,
                            width: 150, // TODO: calculate on fly
                            height: height)
        text.foregroundColor = Colors.textColor
        text.fontSize = fontSize
    }
    
    public var intrinsicContentSize: CGSize {
        return CGSize(width: 2400,
                      height: CGFloat(rects.count) * (height + space))
    }
    
    let height: CGFloat = 8
    let space: CGFloat = 1
    let fontSize: CGFloat = 5

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
