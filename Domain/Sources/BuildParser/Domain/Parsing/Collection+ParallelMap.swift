//
//  Collection+ParallelMap.swift
//  BuildParser
//
//  Created by Mikhail Rubanov on 20.05.2022.
//

import Foundation

extension Collection {
    // Atother implementation https://talk.objc.io/episodes/S01E90-concurrent-map
    func parallelMap<R>(_ transform: @escaping (Element) -> R) -> [R] {
        var res: [R?] = .init(repeating: nil, count: count)
        
        let lock = NSRecursiveLock()
        DispatchQueue.concurrentPerform(iterations: count) { i in
            let result = transform(self[index(startIndex, offsetBy: i)])
            lock.lock()
            res[i] = result
            lock.unlock()
        }
        
        return res.map({ $0! })
    }
    
    func parallelCompactMap<R>(_ transform: @escaping (Element) -> R?) -> [R] {
        var res: [R?] = .init(repeating: nil, count: count)
        
        let lock = NSRecursiveLock()
        DispatchQueue.concurrentPerform(iterations: count) { i in
            if let result = transform(self[index(startIndex, offsetBy: i)]) {
                lock.lock()
                res[i] = result
                lock.unlock()
            }
        }
        
        return res.compactMap { $0 }
    }
}
