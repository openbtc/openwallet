//
//  UIViewPropertyAnimator+BRWAdditions.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-10-26.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
extension UIViewPropertyAnimator {

    static func springAnimation(_ animations: @escaping ()->Void) -> UIViewPropertyAnimator {
        let springParameters = UISpringTimingParameters(dampingRatio: 0.7)
        let animator = UIViewPropertyAnimator(duration: 0.6, timingParameters: springParameters)
        animator.addAnimations(animations)
        return animator
    }

}
