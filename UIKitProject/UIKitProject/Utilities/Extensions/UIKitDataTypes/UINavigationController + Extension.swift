//
//  UINavigationController + Extension.swift
//  UIKitProject
//
//  Created by Rath! on 3/10/25.
//

import Foundation
import UIKit

var isSwipingBack = true

// MARK: Make swiping enble when custom back button
extension UINavigationController: UIGestureRecognizerDelegate {

    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return (viewControllers.count > 1 && isSwipingBack)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
