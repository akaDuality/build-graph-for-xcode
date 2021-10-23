//
//  EventLayer.swift
//  
//
//  Created by Mikhail Rubanov on 23.10.2021.
//

import QuartzCore

class EventLayer: CALayer {
    internal init(
        text: String,
        isLast: Bool) {
        self.text = text
        self.isLast = isLast
        self.textLayer = CATextLayer()
        
        super.init()
        
        addSublayer(textLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(layer: Any) {
        let layer = layer as! EventLayer
        
        self.text = layer.text
        self.isLast = layer.isLast
        self.textLayer = layer.textLayer
        
        super.init(layer: layer)
    }
    
    let text: String
    let isLast: Bool
    
    let textLayer: CATextLayer
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        let textWidth: CGFloat = 150 // TODO: calculate on fly
        let textOffset: CGFloat = 2
        textLayer.string = text
        textLayer.frame = CGRect(
            x: bounds.maxX + textOffset,
            y: bounds.minY + 1,
            width: textWidth,
            height: bounds.height)
        
        if isLast {
            textLayer.alignmentMode = .right
            textLayer.frame = bounds
                .offsetBy(dx: -textWidth - textOffset*4,
                          dy: 0)
        }
        textLayer.foregroundColor = Colors.textColor
        textLayer.fontSize = fontSize
    }
    
    let fontSize: CGFloat = 10
}
