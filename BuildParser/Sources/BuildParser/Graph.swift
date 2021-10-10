//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 09.10.2021.
//

import QuartzCore

class Graph: CALayer {
    let events: [Event]
    let highlightedEvent: Event?
    
    private(set) var shapes: [CALayer]
    private let higlightedLift: CALayer
    private(set) var texts: [CATextLayer]
    private let rects: [EventRelativeRect]
    
    init(events: [Event], highlightedEvent: Event?) {
        self.events = events
        self.highlightedEvent = highlightedEvent
        
        self.rects = events.map { event in
            EventRelativeRect(event: event,
                              absoluteStart: events.start(),
                              totalDuration: events.duration())
        }
        self.shapes = .init()
        self.higlightedLift = .init()
        self.texts = .init()
        
        super.init()
        
        setup(scale: 3)
    }
    
    func setup(scale: CGFloat) {
        
        higlightedLift.backgroundColor = Colors.liftColor
        self.higlightedLift.frame = .zero
        addSublayer(higlightedLift)
        
        for rect in rects {
            let layer = CALayer()
            layer.contentsScale = scale
            layer.backgroundColor = rect.backgroundColor.withAlphaComponent(alpha(for: rect)).cgColor
            shapes.append(layer)
            addSublayer(layer)
            
            let textLayer = CATextLayer()
            textLayer.contentsScale = scale
            texts.append(textLayer)
            self.addSublayer(textLayer)
        }
        
        backgroundColor = Colors.backColor
    }
    
    func alpha(for rect: EventRelativeRect) -> CGFloat {
        if let highlightedEvent = highlightedEvent {
            if rect.event.domain == highlightedEvent.domain {
                return 1
            } else {
                return 0.25
            }
        } else {
            return 1
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
       
        for (i, shape) in shapes.enumerated() {
            let rect = rects[i]
            let frame = frame(for: i, rect: rect)
            shape.frame = frame
            
            drawText(rect: rect, i: i, frame: frame)
            
            if rect.event.taskName == highlightedEvent?.taskName {
                higlightedLift.frame = CGRect(x: frame.minX,
                                              y: 0, width: frame.width,
                                              height: self.frame.height)
            }
        }
    }
    
    private func frame(for i: Int, rect: EventRelativeRect) -> CGRect {
        let width: CGFloat = self.frame.width
        
        return CGRect(x: width * rect.start,
                      y: CGFloat(i) * (height + space),
                      width: width * rect.duration,
                      height: height)
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
