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
        
        guard !wasShown else { return } // Do not show twice in a row
        
        showReview()
    }
    
    private func showReview() {
        SKStoreReviewController.requestReview()
        wasShown = true
    }
    
    private var wasShown = false
    
    private var canShowReview: Bool {
        requestCount >= 5
    }
    
    private var requestCount = 0
}
