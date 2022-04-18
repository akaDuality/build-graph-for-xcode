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
    
    var intrinsicContentSize: CGSize {
        return CGSize(width: 130,
                      height: (lineHeight + space) * CGFloat(Colors.Events.legend.count) + inset * 2)
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
            
            subview.frame = CGRect(x: inset,
                                   y: inset + (lineHeight + 4) * CGFloat(index),
                                   width: frame.width - inset*2,
                                   height: lineHeight)
        }
    }
    
    let lineHeight: CGFloat = 14
    let inset: CGFloat = 8
    let space: CGFloat = 4
}
