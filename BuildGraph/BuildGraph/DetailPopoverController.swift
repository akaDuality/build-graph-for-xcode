//
//  DetailPopoverController.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 31.10.2021.
//

import Foundation
import AppKit

class DetailPopoverController: NSViewController {
    @IBOutlet weak var textView: NSTextView!
    
    var text: String = "" {
        didSet {
            textView.string = text
        }
    }
    
    override var preferredContentSize: NSSize {
        get {
            CGSize(
                width: 600,
                height: textView.contentSize.height
                + 30 // TODO: calculate
            )
        }
        
        set {}
    }
}

extension NSTextView {
    
    var contentSize: CGSize {
        get {
            guard let layoutManager = layoutManager,
                  let textContainer = textContainer else {
                print("textView no layoutManager or textContainer")
                return .zero
            }
            
            layoutManager.ensureLayout(for: textContainer)
            return layoutManager.usedRect(for: textContainer).size
        }
    }
}
