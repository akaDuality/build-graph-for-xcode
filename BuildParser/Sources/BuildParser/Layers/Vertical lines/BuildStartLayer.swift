//
//  BuildStartLayer.swift
//  
//
//  Created by Mikhail Rubanov on 04.04.2022.
//

import QuartzCore

class BuildStartLayer: VerticalLineLayer {
    
    var relativeBuildStart: CGFloat = 0 {
        didSet {
            concurrencyTitle.string = NSLocalizedString("Build starts here", comment: "")
            color = Colors.Events.cached()
        }
    }
    
    public override init(scale: CGFloat) {
        super.init(scale: scale)
    }
    
    public override init(layer: Any) {
        let layer = layer as! BuildStartLayer
        
        self.relativeBuildStart = layer.relativeBuildStart
        
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        self.coordinate = CGPoint(x: relativeBuildStart * bounds.width, y: 30)
    }
}
