//
//  ColorDescriptionLayer.swift
//  
//
//  Created by Mikhail Rubanov on 06.03.2022.
//

import Foundation
import AppKit

class ColorDescriptionLayer: CALayer {
    let colorLayer: CALayer
    let descriptionLayer: CATextLayer
    
    init(colorDescription: ColorDescription, scale: CGFloat) {
        self.colorLayer = CALayer()
        self.descriptionLayer = CATextLayer()
        
        super.init()
        
        colorLayer.backgroundColor = colorDescription.color
        colorLayer.contentsScale = scale
        addSublayer(colorLayer)
        
        descriptionLayer.contentsScale = scale
        descriptionLayer.string = colorDescription.desc
        descriptionLayer.foregroundColor = Colors.textColor()
        descriptionLayer.fontSize = 10
        addSublayer(descriptionLayer)
        
        colorLayer.cornerRadius = 2
        if #available(macOS 10.15, *) {
            colorLayer.cornerCurve = .continuous
        }
    }
    
    public override init(layer: Any) {
        let layer = layer as! ColorDescriptionLayer
        
        self.colorLayer = layer.colorLayer
        self.descriptionLayer = layer.descriptionLayer
        
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        colorLayer.frame = CGRect(x: 0,
                                  y: 0,
                                  width: 50,
                                  height: frame.height)
        descriptionLayer.frame = CGRect(x: colorLayer.frame.maxX + 8,
                                        y: 0,
                                        width: 150,
                                        height: frame.height)
    }
}
