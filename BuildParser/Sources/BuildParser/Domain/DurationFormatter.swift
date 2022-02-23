//
//  DurationFormatter.swift
//  
//
//  Created by Mikhail Rubanov on 23.02.2022.
//

import Foundation

public class DurationFormatter {
    
    public init() {}
    
    lazy var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.allowsFractionalUnits = true
        return formatter
    }()
    
    public func string(from ti: TimeInterval) -> String {
        guard ti >= 1 else {
            return formatMillisecons(from: ti)
        }
        
        return durationFormatter.string(from: ti) ?? ""
    }
    
    private func formatMillisecons(from ti: TimeInterval) -> String {
        if ti == 0     { return "" }
        if ti <= 0.001 { return "< 1ms" }
        if ti < 0.01   { return String(format: "%.2fs", ti) }
        if ti < 0.1    { return String(format: "%.2fs", ti) }
        if ti < 1      { return String(format: "%.1fs", ti) }
        
        return ""
    }
}
