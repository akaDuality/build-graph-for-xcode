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
        event: Event) {
        self.event = event
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
        self.spaceToRigth = layer.spaceToRigth
        self.textLayer = layer.textLayer
        self.stepShapes = layer.stepShapes
        
        super.init(layer: layer)
    }
    
    let event: Event
    var spaceToRigth: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
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
        let textWidth: CGFloat = 200 // TODO: calculate on fly
        let textOffset: CGFloat = 2
        textLayer.string = event.description
        textLayer.frame = CGRect(
            x: bounds.maxX + textOffset,
            y: bounds.minY + 1,
            width: textWidth,
            height: bounds.height)
        
        if spaceToRigth < textWidth {
            textLayer.alignmentMode = .right
            textLayer.foregroundColor = Colors.textInvertedColor()
            
            if self.frame.width < textWidth {
                textLayer.frame = textLayer.frame
                    .offsetBy(dx: -textOffset*4 - textWidth - self.frame.width,
                              dy: 0)
            } else {
                textLayer.frame = textLayer.frame
                    .offsetBy(dx: -textOffset*4 - textWidth,
                              dy: 0)
            }
        }
    }
    
    let fontSize: CGFloat = 10
}
