//
//  TimelineLayer.swift
//  
//
//  Created by Mikhail Rubanov on 15.10.2021.
//

import QuartzCore
import Foundation

class TimelineLayer: CALayer {
    
    let eventsDuration: TimeInterval
    
    var ticks: [CALayer]
    var minuteTitles: [CATextLayer]
    
    let currentTime: CATextLayer
    
    public var coordinate: CGPoint? = .zero {
        didSet {
            updateWithoutAnimation {
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    
    public init(eventsDuration: TimeInterval, scale: CGFloat) {
        self.eventsDuration = eventsDuration
        self.ticks = [CALayer]()
        self.minuteTitles = [CATextLayer]()
        self.currentTime = CATextLayer()
        super.init()
        
        setup(scale: scale)
    }
    
    public override init(layer: Any) {
        let layer = layer as! TimelineLayer
        
        self.eventsDuration = layer.eventsDuration
        self.ticks = layer.ticks
        self.minuteTitles = layer.minuteTitles
        self.currentTime = layer.currentTime
        
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(scale: CGFloat) {
        for _ in 0..<eventsDuration.seconds {
            let tickLayer = CALayer()
            tickLayer.backgroundColor = Colors.timeColor
            addSublayer(tickLayer)
            
            ticks.append(tickLayer)
        }
        
        for _ in 0...eventsDuration.minutes {
            let titleLayer = CATextLayer()
            titleLayer.foregroundColor = Colors.timeColor
            titleLayer.fontSize = 20
            
            addSublayer(titleLayer)
            
            minuteTitles.append(titleLayer)
        }
        
        currentTime.foregroundColor = Colors.timeColor
        currentTime.fontSize = 20
        
        addSublayer(currentTime)
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        let minuteHeight: CGFloat = 30
        let quarterHeight: CGFloat = 20
        let secondHeight: CGFloat = 10
        
        let secondWidth: CGFloat = frame.width / CGFloat(eventsDuration.seconds)
        
        for second in 1..<eventsDuration.seconds {
            let tickLayer = ticks[second]
            
            var height: CGFloat = secondHeight
            if second.isMinuteStart {
                height = minuteHeight
            } else if second.isMinuteQuart {
                height = quarterHeight
            } else {
                height = secondHeight
                tickLayer.isHidden = second % 5 != 0
            }
            
            let y: CGFloat = frame.height - height
            let frame = CGRect(x: secondWidth * CGFloat(second),
                               y: y,
                               width: 1,
                               height: height)
            tickLayer.frame = frame
            
            if second.isMinuteStart {
                let width: CGFloat = 20
                let title = minuteTitles[second.minute]
                title.string = "\(second.minute)"
                title.frame = CGRect(x: frame.minX - width + 5,
                                     y: frame.minY - 6,
                                     width: width,
                                     height: minuteHeight)
            }
        }
        
        // MARK: Pointer
        if let coordinate = coordinate {
            let width: CGFloat = 60
            let time = TimeInterval(coordinate.x / frame.width) * eventsDuration
            currentTime.string = dateFormatter.string(from: Date(timeIntervalSince1970: time))
            
            let frame = CGRect(x: coordinate.x + 5,
                               y: frame.height - minuteHeight * 2,
                               width: width,
                               height: minuteHeight)
            
            if coordinate.x < self.frame.width - width {
                currentTime.alignmentMode = .left
                currentTime.frame = frame
            } else {
                currentTime.alignmentMode = .right
                currentTime.frame = frame.offsetBy(dx: -width - 10, dy: 0)
            }
            
            currentTime.isHidden = false
        } else {
            currentTime.isHidden = true
        }
        
        
    }
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
//        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "m:ss"
        return dateFormatter
    }()
}

extension TimeInterval {
    var minutes: Int {
        seconds / 60
    }
    var seconds: Int {
        Int(self)
    }
    var secondsInMinute: Int {
        seconds % 60
    }
}

fileprivate extension Int {
    var isMinuteStart: Bool {
        self % 60 == 0
    }
    
    var isMinuteQuart: Bool {
        self % 15 == 0
    }
    
    var minute: Int {
        self / 60
    }
}
