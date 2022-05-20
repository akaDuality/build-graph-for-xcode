//
//  TestBundle.swift
//  BuildParserTests
//
//  Created by Mikhail Rubanov on 29.04.2022.
//

import Foundation

class TestBundle {
    var paymentSDK: URL {
        Bundle(for: TestBundle.self)
            .url(forResource: "F5F5EB7C-FD56-4037-9959-7056E5363FCD",
                 withExtension: "xcactivitylog")!
    }
}
