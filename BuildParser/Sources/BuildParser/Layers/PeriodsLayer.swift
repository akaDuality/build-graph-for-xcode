//
//  PeriodsLayer.swift
//  
//
//  Created by Mikhail Rubanov on 13.10.2021.
//

import QuartzCore
import Foundation

class PeriodsLayer: CALayer {
    private let periods: [Period]
    private var periodsShapes: [CALayer]
    
    private let start: Date
    private let totalDuration: TimeInterval
    
    init(periods: [Period], start: Date, totalDuration: TimeInterval) {
        self.periods = periods
        self.periodsShapes = [CALayer]()
        self.start = start
        self.totalDuration = totalDuration
        super.init()
        setup()
    }
    
    public override init(layer: Any) {
        let layer = layer as! PeriodsLayer
        
        self.periods = layer.periods
        self.periodsShapes = layer.periodsShapes
        self.start = layer.start
        self.totalDuration = layer.totalDuration
        
        super.init(layer: layer)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        for period in periods {
            let periodLayer = CALayer()
            let alpha: CGFloat = 1 / CGFloat(period.concurrency)
            periodLayer.backgroundColor = Colors.concurencyColor.copy(alpha: alpha / 4)
            periodsShapes.append(periodLayer)
            addSublayer(periodLayer)
        }
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        for (i, period) in periods.enumerated() {
            let layer = periodsShapes[i]
            
            let relativeStart = relativeStart(absoluteStart: start,
                                              start: period.start,
                                              duration: totalDuration)
            let relativeDuration = relativeDuration(start: period.start,
                                                    end: period.end,
                                                    duration: totalDuration)
            layer.frame = CGRect(
                x: relativeStart * self.frame.width,
                y: 0,
                width: relativeDuration * self.frame.width,
                height: frame.height
            )
        }
    }
    
    static public let periodsHeight: CGFloat = 10
}
