//
//  AppReview.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 16.04.2022.
//

import Foundation
import StoreKit

class AppReview {
    func requestIfPossible() {
        guard canShowReview else {
            requestCount += 1
            return
        }
        
        SKStoreReviewController.requestReview()
    }
    
    private var canShowReview: Bool {
        requestCount >= 5
    }
    
    private var requestCount = 0
}
