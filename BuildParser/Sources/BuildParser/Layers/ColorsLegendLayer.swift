//
//  ColorsLegendLayer.swift
//  
//
//  Created by Mikhail Rubanov on 19.01.2022.
//

import QuartzCore

class ColorsLegendLayer: CALayer {
    
    var colorDescriptionLayers: [ColorDescriptionLayer]
     
    init(scale: CGFloat) {
        colorDescriptionLayers = []
        
        for colorDescription in Colors.Events.legend {
            colorDescriptionLayers.append(
                ColorDescriptionLayer(colorDescription: colorDescription,
                                      scale: scale)
            )
        }
        
        super.init()
        
        self.contentsScale = scale
        
        for subview in colorDescriptionLayers {
            subview.contentsScale = scale
            addSublayer(subview)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(layer: Any) {
        let layer = layer as! ColorsLegendLayer
        
        self.colorDescriptionLayers = layer.colorDescriptionLayers
        
        super.init(layer: layer)
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        backgroundColor = Colors.Events.legendBackground().copy(alpha: 0.25)
        
        cornerRadius = 10
        if #available(macOS 10.15, *) {
            cornerCurve = .continuous
        }
        
        for (index, subview) in colorDescriptionLayers.enumerated() {
            let height: CGFloat = 14
            subview.frame = CGRect(x: 8,
                                   y: 8 + (height + 4) * CGFloat(index),
                                   width: frame.width - 8*2,
                                   height: height)
        }
    }
}

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
