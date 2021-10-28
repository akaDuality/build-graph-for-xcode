//
//  DependeciesLayer.swift
//  
//
//  Created by Mikhail Rubanov on 24.10.2021.
//

import QuartzCore
import Interface

class DependeciesLayer: ModulesLayer {
   
    var showLinks: Bool = true {
        didSet {
            criticalDependenciesLayer.isHidden = !showLinks
            regularDependenciesLayer.isHidden = !showLinks
        }
    }
    
    var dependencies: [Dependency] = []
    
    lazy var criticalDependenciesLayer: CAShapeLayer = {
        let bezierLayer = CAShapeLayer()
        bezierLayer.strokeColor = Colors.criticalDependencyColor
        bezierLayer.fillColor = Colors.clear
        bezierLayer.lineWidth = 1
        addSublayer(bezierLayer)
        
        return bezierLayer
    }()
    
    lazy var regularDependenciesLayer: CAShapeLayer = {
        let bezierLayer = CAShapeLayer()
        bezierLayer.strokeColor = Colors.regularDependencyColor
        bezierLayer.fillColor = Colors.clear
        bezierLayer.lineWidth = 1
        addSublayer(bezierLayer)
        
        return bezierLayer
    }()
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        drawConnections(for: highlightedEvent)
    }
    
    func drawConnections(for event: Event?) {
        regularPath = CGMutablePath()
        criticalPath = CGMutablePath()
        
        for dependency in dependencies {
            
            // TODO: Calc indexes at models layer
            guard let fromIndex = events.index(name: dependency.target.target)
            else { continue }
            
            for target in dependency.dependencies {
                
                let isHighlightedModule = target.target == event?.taskName
                || dependency.target.target == event?.taskName
                
                guard let toIndex = events.index(name: target.target)
                else { continue }
                
                guard fromIndex != toIndex
                else { continue }
                
                connectModules(
                    from: shapes[toIndex],
                    to: shapes[fromIndex],
                    on: regularPath,
                    isHighlightedModule: isHighlightedModule
                )
            }
        }
        
        regularDependenciesLayer.frame = bounds
        regularDependenciesLayer.path = regularPath
        
        criticalDependenciesLayer.frame = bounds
        criticalDependenciesLayer.path = criticalPath
    }
    
    var regularPath = CGMutablePath()
    var criticalPath = CGMutablePath()
    
    func connectModules(
        from: CALayer,
        to: CALayer,
        on path: CGMutablePath,
        isHighlightedModule: Bool)
    {
        let isBlockerDependency = (to.frame.minX - from.frame.maxX) / bounds.width < 0.05
        
        guard (isBlockerDependency && highlightedEvent == nil)
                || isHighlightedModule else {
                    return
                }
        
        connect(from: from.frame.rightBottom,
                to: to.frame.leftCenter,
                on: isBlockerDependency ? criticalPath : regularPath)
    }
    
    func connect(
        from: CGPoint,
        to: CGPoint,
        on path: CGMutablePath)
    {
        let offset: CGFloat = max(10, to.x - from.x)
        path.move(to: from)
        path.addCurve(to: to,
                      control1: from.offset(x: 0, y: 0),
                      control2: to.offset(x: -offset, y: 0),
                      transform: .identity)
    }
}

extension CGRect {
    
    var rightBottom: CGPoint {
        CGPoint(x: maxX, y: maxY)
    }
    
    var rightCenter: CGPoint {
        CGPoint(x: maxX, y: midY)
    }
    
    var bottomCenter: CGPoint {
        CGPoint(x: midX, y: maxY)
    }
    
    var leftCenter: CGPoint {
        CGPoint(x: minX, y: midY)
    }
}

extension CGPoint {
    func offset(x: CGFloat, y: CGFloat) -> CGPoint {
        CGPoint(x: self.x + x,
                y: self.y + y)
    }
}

extension Array where Element == Event {
    public func index(name: String) -> Int? {
        firstIndex { event in
            event.taskName == name
        }
    }
}
