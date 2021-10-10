//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 09.10.2021.
//

import UIKit

class Graph: UIView {
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
        
        super.init(frame: .zero)
        
        setup()
    }
    
    func setup() {
        
        higlightedLift.backgroundColor = UIColor.white.withAlphaComponent(0.05).cgColor
        self.higlightedLift.frame = .zero
        layer.addSublayer(higlightedLift)
        
        for rect in rects {
            let layer = CALayer()
            layer.contentsScale = UIScreen.main.scale
            layer.backgroundColor = rect.backgroundColor.withAlphaComponent(alpha(for: rect)).cgColor
            shapes.append(layer)
            self.layer.addSublayer(layer)
            
            let textLayer = CATextLayer()
            textLayer.contentsScale = UIScreen.main.scale
            texts.append(textLayer)
            self.layer.addSublayer(textLayer)
        }
        
        backgroundColor = .darkGray
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
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
        text.foregroundColor = UIColor.label.cgColor
        text.fontSize = fontSize
    }
    
    let height: CGFloat = 8
    let space: CGFloat = 1
    let fontSize: CGFloat = 5
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 2400,
                      height: CGFloat(rects.count) * (height + space))
    }
}
