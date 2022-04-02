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
        fontSize: CGFloat,
        scale: CGFloat)
    {
        self.event = event
        self.fontSize = fontSize
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
        textLayer.font = NSFont.systemFont(ofSize: fontSize)
        textLayer.fontSize = fontSize
        addSublayer(textLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(layer: Any) {
        let layer = layer as! EventLayer
        
        self.event = layer.event
        self.fontSize = layer.fontSize
        self.textLayer = layer.textLayer
        self.stepShapes = layer.stepShapes
        
        super.init(layer: layer)
    }
    
    let event: Event
    let fontSize: CGFloat
    
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
    
    func layoutText(spaceToLeft: CGFloat, spaceToRight: CGFloat) {
        textLayer.string = event.description
        textLayer.backgroundColor = NSColor.red.cgColor
        
        let textWidth: CGFloat = event.description
            .size(OfFont: NSFont.systemFont(ofSize: textLayer.fontSize))
            .width
        
        if spaceToLeft > textWidth {
            textLayer.foregroundColor = Colors.textInvertedColor()
            layoutLeft(textWidth)
        } else if spaceToRight > textWidth {
            textLayer.foregroundColor = Colors.textInvertedColor()
            layoutRight(textWidth)
        } else {
            textLayer.foregroundColor = Colors.textOverModuleColor()
            layoutInsideRight(textWidth)
        }
    }
    
    let textOffset: CGFloat = 4
    
    private func layoutRight(_ textWidth: CGFloat) {
        textLayer.alignmentMode = .left
        textLayer.frame = CGRect(
            x: bounds.maxX + textOffset,
            y: bounds.minY + 1,
            width: textWidth,
            height: bounds.height)
    }
    
    private func layoutLeft(_ textWidth: CGFloat) {
        textLayer.alignmentMode = .right
        textLayer.frame = CGRect(
            x: bounds.minX - textOffset - textWidth,
            y: bounds.minY + 1,
            width: textWidth,
            height: bounds.height)
    }
    
    private func layoutInsideRight(_ textWidth: CGFloat) {
        textLayer.alignmentMode = .right
        textLayer.frame = CGRect(
            x: bounds.minX + textOffset,
            y: bounds.minY + 1,
            width: textWidth,
            height: bounds.height)
        textLayer.alignmentMode = .left
    }
}

extension String {
    func size(OfFont font: NSFont) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
    }
}
