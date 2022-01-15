//
//  ConcurrencyLayer.swift
//  
//
//  Created by Mikhail Rubanov on 13.10.2021.
//

import QuartzCore

class ConcurrencyLayer: CALayer {
    private let events: [Event]
    
    private let concurrencyLine: CALayer
    private let concurrencyTitle: CATextLayer
    
    public var coordinate: CGPoint? = .zero {
        didSet {
            updateWithoutAnimation {
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    
    private var concurrencyHidden: Bool = false {
        didSet {
            let opacity: Float = concurrencyHidden ? 0: 1
            concurrencyLine.opacity = opacity
            concurrencyTitle.opacity = opacity
        }
    }
    
    public init(events: [Event], scale: CGFloat) {
        self.events = events
        self.concurrencyLine = CALayer()
        self.concurrencyTitle = CATextLayer()
        
        super.init()
        
        setup(scale: scale)
    }
    
    public override init(layer: Any) {
        let layer = layer as! ConcurrencyLayer
        
        self.events = layer.events
        self.concurrencyLine = layer.concurrencyLine
        self.concurrencyTitle = layer.concurrencyTitle
        self.coordinate = layer.coordinate
        
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawConcurrency(at coordinate: CGPoint) {
        self.coordinate = coordinate
        
        let relativeX = coordinate.x / frame.width
        let time = events.duration() * relativeX
        let concurency = events.concurrency(at: time)
        concurrencyTitle.string = "\(concurency)"
    }
    
    private func setup(scale: CGFloat) {
        concurrencyLine.backgroundColor = Colors.concurencyColor()
        addSublayer(concurrencyLine)
        
        concurrencyTitle.contentsScale = scale
        concurrencyTitle.foregroundColor = Colors.concurencyColor()
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
            concurrencyTitle.frame = CGRect(x: coordinate.x + 10,
                                            y: coordinate.y - titleHeight - 10,
                                            width: 100,
                                            height: titleHeight)
        } else {
            concurrencyHidden = true
        }
        
    }
}
