//
//  VerticalLineLayer.swift
//  
//
//  Created by Mikhail Rubanov on 04.04.2022.
//

import QuartzCore

class VerticalLineLayer: CALayer {
    
    var color = Colors.concurencyColor() {
        didSet {
            concurrencyLine.backgroundColor = color
            concurrencyTitle.foregroundColor = color
        }
    }
    
    private let concurrencyLine: CALayer
    let concurrencyTitle: CATextLayer
    
    public var coordinate: CGPoint? = .zero
    
    func updateLayoutWithoutAnimation() {
        updateWithoutAnimation {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private var concurrencyHidden: Bool = false {
        didSet {
            let opacity: Float = concurrencyHidden ? 0: 1
            concurrencyLine.opacity = opacity
            concurrencyTitle.opacity = opacity
        }
    }
    
    public init(scale: CGFloat) {
        self.concurrencyLine = CALayer()
        self.concurrencyTitle = CATextLayer()
        
        super.init()
        
        setup(scale: scale)
    }
    
    public override init(layer: Any) {
        let layer = layer as! VerticalLineLayer
        
        self.concurrencyLine = layer.concurrencyLine
        self.concurrencyTitle = layer.concurrencyTitle
        self.coordinate = layer.coordinate
        
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(scale: CGFloat) {
        concurrencyLine.contentsScale = scale
        addSublayer(concurrencyLine)
        
        concurrencyTitle.contentsScale = scale
        concurrencyTitle.fontSize = 20
        addSublayer(concurrencyTitle)
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        if let coordinate = coordinate {
            concurrencyHidden = false
            concurrencyLine.frame = CGRect(x: coordinate.x,
                                           y: 0,
                                           width: 1,
                                           height: frame.height)
            let titleHeight: CGFloat = 20
            let titleWidth: CGFloat = 150
            if coordinate.x < bounds.width - titleWidth - 10 {
                // Draw right
                concurrencyTitle.alignmentMode = .left
                concurrencyTitle.frame = CGRect(x: coordinate.x + 10,
                                                y: coordinate.y - titleHeight - 10,
                                                width: titleWidth,
                                                height: titleHeight)
            } else {
                // Dras left
                concurrencyTitle.alignmentMode = .right
                concurrencyTitle.frame = CGRect(x: coordinate.x - 10 - titleWidth,
                                                y: coordinate.y - titleHeight - 10,
                                                width: titleWidth,
                                                height: titleHeight)
            }
        } else {
            concurrencyHidden = true
        }
    }
}
