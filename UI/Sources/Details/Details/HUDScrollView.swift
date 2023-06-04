//
//  HUDScrollView.swift
//  BuildGraph
//
//  Created by Mikhail Rubanov on 06.03.2022.
//

import Foundation
import AppKit
import BuildParser

class HUDScrollView: NSScrollView {
    var hudLayer: HUDLayer?
    
//    func observeScrollChange() {
////        allowsMagnification = false // Here is a problem with smooth zoom by touchpad
//
//        contentView.postsBoundsChangedNotifications = true
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(didScrollContent),
//                                               name: NSView.boundsDidChangeNotification,
//                                               object: nil)
//    }
//
//    @objc func didScrollContent() {
////        hudLayer?.updateWithoutAnimation {
////            hudLayer?.frame = contentView.bounds.offsetBy(dx: 0, dy: 52) // TODO: Remove hardcode
////        }
//
//        hudLayer?.updateScale(to: magnification)
//    }
}
