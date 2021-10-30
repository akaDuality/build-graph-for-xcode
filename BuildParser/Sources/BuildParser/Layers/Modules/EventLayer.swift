//
//  EventLayer.swift
//  
//
//  Created by Mikhail Rubanov on 23.10.2021.
//

import QuartzCore
import Interface
import AppKit

class EventLayer: CALayer {
    internal init(
        event: Event,
        isLast: Bool) {
        self.event = event
        self.isLast = isLast
        self.textLayer = CATextLayer()
        self.stepShapes = [CALayer]()
        super.init()
            
        for _ in event.steps {
            let layer = CALayer()
            layer.backgroundColor = NSColor.systemOrange.cgColor
            addSublayer(layer)
            stepShapes.append(layer)
        }
            
        textLayer.foregroundColor = Colors.textColor
        textLayer.fontSize = fontSize
        addSublayer(textLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(layer: Any) {
        let layer = layer as! EventLayer
        
        self.event = layer.event
        self.isLast = layer.isLast
        self.textLayer = layer.textLayer
        self.stepShapes = layer.stepShapes
        
        super.init(layer: layer)
    }
    
    let event: Event
    let isLast: Bool
    let textLayer: CATextLayer
    var stepShapes: [CALayer]
   
    var showSubtask: Bool = true {
        didSet {
            for stepShapes in stepShapes {
                stepShapes.isHidden = !showSubtask
            }
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        layoutSubtasks()
        layoutText()
    }
    
    private func layoutSubtasks() {
        for (i, step) in event.steps.enumerated() {
            let shape = stepShapes[i]
           
            guard event.duration != 0 else { continue }
            
            let relativeStartDate = step.startDate.timeIntervalSince(event.startDate) / event.duration
            let relativeDuration = step.duration / event.duration
           
            shape.frame = CGRect(x: CGFloat(relativeStartDate) * frame.width,
                                 y: 0,
                                 width: CGFloat(relativeDuration) * frame.width,
                                 height: self.frame.height)
        }
    }
    
    private func layoutText() {
        let textWidth: CGFloat = 150 // TODO: calculate on fly
        let textOffset: CGFloat = 2
        textLayer.string = event.description
        textLayer.frame = CGRect(
            x: bounds.maxX + textOffset,
            y: bounds.minY + 1,
            width: textWidth,
            height: bounds.height)
        
        if isLast {
            textLayer.alignmentMode = .right
            textLayer.frame = bounds
                .offsetBy(dx: -textOffset*4,
                          dy: 0)
            textLayer.foregroundColor = Colors.backColor
        }
    }
    
    let fontSize: CGFloat = 10
}
