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
        self.contentsScale = scale
        guard eventsDuration.seconds > 0 else {
            return // Sometimes duration is negative for cached modules
            // TODO: Rework to optional constructor
        }
        
        addTicks()
        
        currentTime.foregroundColor = Colors.timeColor()
        currentTime.fontSize = 20
        
        addSublayer(currentTime)
    }
    
    private var drawTicks: Bool {
        eventsDuration.seconds < 3600 // 1 hour
    }
    
    private func addTicks() {
        guard drawTicks else { return }
        
        for _ in 0..<eventsDuration.seconds {
            let tickLayer = CALayer()
            tickLayer.backgroundColor = Colors.timeColor()
            addSublayer(tickLayer)
            
            ticks.append(tickLayer)
        }
        
        for _ in 0...eventsDuration.minutes {
            let titleLayer = CATextLayer()
            titleLayer.foregroundColor = Colors.timeColor()
            titleLayer.fontSize = 18
            
            addSublayer(titleLayer)
            
            minuteTitles.append(titleLayer)
        }
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
       
        guard eventsDuration.seconds > 1 else {
            return // Drawing starts from seconds.
            // TODO: Add milliseconds for this case
        }
        
        layoutSeconds()
        
        layoutCurrentTime()
    }
    
    private let minuteHeight: CGFloat = 30
    private let quarterHeight: CGFloat = 15
    private let secondHeight: CGFloat = 10
    
    private func layoutSeconds() {
        guard drawTicks else { return }
        
        let secondWidth: CGFloat = frame.width / CGFloat(eventsDuration.seconds)
        let minutesWidth: CGFloat = frame.width / CGFloat(eventsDuration.minutes)
        
        for second in 1..<eventsDuration.seconds {
            let tickLayer = ticks[second]
            
            var height: CGFloat = secondHeight
            if second.isMinuteStart {
                height = minuteHeight
            } else if second.isMinuteQuart {
                height = quarterHeight
                tickLayer.isHidden = minutesWidth < 10 // can't draw 3 tick in minutes
            } else {
                // just seconds
                height = secondHeight
                tickLayer.isHidden = second % 5 != 0 || minutesWidth < 20 // can't draw even qurter tick
            }
            
            let y: CGFloat = frame.height - height
            let frame = CGRect(x: secondWidth * CGFloat(second),
                               y: y,
                               width: 1,
                               height: height)
            tickLayer.frame = frame
            
            if second.isMinuteStart {
                let width: CGFloat = 30
                let title = minuteTitles[second.minute]
                title.string = "\(second.minute)"
                title.frame = CGRect(x: frame.minX - width - 2,
                                     y: frame.minY - 6,
                                     width: width,
                                     height: minuteHeight)
                title.alignmentMode = .right
                
                title.isHidden = minutesWidth < 30
                && second % (60*5) != 0 // every 5 is shown
            }
        }
    }
    
    private func layoutCurrentTime() {
        // MARK: Pointer
        let coordinate = coordinate ?? CGPoint(x: frame.maxX, y: 0)
        // TODO: Size text to fit
        let textWidth: CGFloat = 100
        let time = TimeInterval(coordinate.x / frame.width) * eventsDuration
        
        currentTime.updateWithoutAnimation {
            currentTime.string = dateFormatter.string(from: time)
        }
        
        let frame = CGRect(x: coordinate.x + 5,
                           y: frame.height - minuteHeight * 2,
                           width: textWidth,
                           height: minuteHeight)
        
        if coordinate.x < self.frame.width - textWidth {
            currentTime.alignmentMode = .left
            currentTime.frame = frame
        } else {
            currentTime.alignmentMode = .right
            currentTime.frame = frame.offsetBy(dx: -textWidth - 20, dy: 0)
        }
    }
    
    lazy var dateFormatter = DurationFormatter()
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
