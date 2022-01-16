//
//  EventLayer.swift
//  
//
//  Created by Mikhail Rubanov on 23.10.2021.
//

import QuartzCore
import AppKit

class EventLayer: CALayer {
    internal init(
        event: Event,
        scale: CGFloat)
    {
        self.event = event
        self.textLayer = CATextLayer()
        self.stepShapes = [CALayer]()
        super.init()
        self.contentsScale = scale
        
        backgroundColor = event.backgroundColor
        
        for _ in event.steps {
            let layer = CALayer()
            layer.backgroundColor = event.subtaskColor
            layer.contentsScale = scale
            addSublayer(layer)
            stepShapes.append(layer)
        }
        
        textLayer.foregroundColor = Colors.textColor()
        textLayer.contentsScale = scale
        textLayer.fontSize = fontSize
        addSublayer(textLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(layer: Any) {
        let layer = layer as! EventLayer
        
        self.event = layer.event
        self.textLayer = layer.textLayer
        self.stepShapes = layer.stepShapes
        
        super.init(layer: layer)
    }
    
    let event: Event
    var spaceToLeft: CGFloat {
        frame.minX
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
        textLayer.string = event.description
        
        if spaceToLeft < textWidth {
            textLayer.foregroundColor = Colors.textInvertedColor()
            layoutRight()
        } else {
            layoutLeft()
        }
    }
    
    let textWidth: CGFloat = 200 // TODO: calculate on fly
    let textOffset: CGFloat = 4
    
    func layoutRight() {
        textLayer.alignmentMode = .left
        textLayer.frame = CGRect(
            x: bounds.maxX + textOffset,
            y: bounds.minY + 1,
            width: textWidth,
            height: bounds.height)
    }
    
    func layoutLeft() {
        textLayer.alignmentMode = .right
        textLayer.frame = CGRect(
            x: bounds.minX - textOffset - textWidth,
            y: bounds.minY + 1,
            width: textWidth,
            height: bounds.height)
    }
    
//    func layoutInside() {
//        textLayer.alignmentMode = .right
//        textLayer.frame = CGRect(
//            x: bounds.maxX - textOffset - textWidth,
//            y: bounds.minY + 1,
//            width: textWidth,
//            height: bounds.height)
//    }
    
    let fontSize: CGFloat = 10
}
