//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 09.10.2021.
//

import QuartzCore

public class Graph: CALayer {
    let events: [Event]
    public var highlightedEvent: Event? = nil {
        didSet {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            setNeedsLayout()
            layoutIfNeeded()
            CATransaction.commit()
            
            higlightedLift.opacity = (highlightedEvent != nil) ? 1: 0
        }
    }
    
    private(set) var shapes: [CALayer]
    private let higlightedLift: CALayer
    private(set) var texts: [CATextLayer]
    private let rects: [EventRelativeRect]
    
    public init(events: [Event]) {
        self.events = events
        
        self.rects = events.map { event in
            EventRelativeRect(event: event,
                              absoluteStart: events.start(),
                              totalDuration: events.duration())
        }
        self.shapes = .init()
        self.higlightedLift = .init()
        self.texts = .init()
        
        super.init()
        
        setup(scale: contentsScale)
    }
    public override init(layer: Any) {
        let layer = layer as! Graph
        
        self.events = layer.events
        self.shapes = layer.shapes
        self.texts = layer.texts
        self.higlightedLift = layer.higlightedLift
        self.rects = layer.rects
        super.init(layer: layer)
    }
   
    // MARK: - Event
    public func highlightEvent(at coordinate: CGPoint) {
        let event = event(at: coordinate)
        highlightedEvent = event
    }
    
    private func event(at coorditate: CGPoint) -> Event? {
        for (i, shape) in shapes.enumerated() {
            if shape
                .frame.insetBy(dx: 0, dy: -space/2)
                .inLine(coorditate) {
                return events[i]
            }
        }
        return nil
    }
    
    // MARK: - Drawing
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
        
        backgroundColor = Colors.backColor
    }
    
    private func alpha(for rect: EventRelativeRect) -> CGFloat {
        if let highlightedEvent = highlightedEvent {
            if rect.event.domain == highlightedEvent.domain {
                return 1
            } else {
                return 0.1
            }
        } else {
            return 1
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        for (i, shape) in shapes.enumerated() {
            let rect = rects[i]
            let frame = frame(for: i, rect: rect)
            shape.frame = frame
            shape.backgroundColor = rect.backgroundColor.copy(alpha: alpha(for: rect))
            
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
        let height = self.frame.height
        
        return CGRect(x: width * rect.start,
                      y: height - CGFloat(i) * (self.height + space),
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
    
    let height: CGFloat = 8
    let space: CGFloat = 1
    let fontSize: CGFloat = 5

    var intrinsicContentSize: CGSize {
        return CGSize(width: 2400,
                      height: CGFloat(rects.count) * (height + space))
    }
}
extension CGRect {
    func inLine(_ coordinate: CGPoint) -> Bool {
        (minY...maxY).contains(coordinate.y)
    }
}
