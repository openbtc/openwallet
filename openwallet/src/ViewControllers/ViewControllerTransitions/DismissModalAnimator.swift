//
//  DismissModalAnimator.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-25.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

//TODO - figure out who should own this
let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

class DismissModalAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let modalHeight: CGFloat = 368.0

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard transitionContext.isAnimated else { return }
        let duration = transitionDuration(using: transitionContext)
        guard let fromView = transitionContext.view(forKey: .from) else { assert(false, "Empty from view"); return }
        guard let toView = transitionContext.view(forKey: .to) else { assert(false, "Empty to view"); return }

        UIView.animate(withDuration: duration, animations: {
            blurView.alpha = 0.0
            fromView.frame = self.hiddenFrame(fromFrame: toView.frame)
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    func visibleFrame(fromFrame: CGRect) -> CGRect {
        var newFrame = fromFrame
        newFrame.origin.y = fromFrame.maxY - modalHeight
        newFrame.size.height = modalHeight
        return newFrame
    }

    func hiddenFrame(fromFrame: CGRect) -> CGRect {
        var newFrame = fromFrame
        newFrame.origin.y = fromFrame.size.height
        newFrame.size.height = modalHeight
        return newFrame
    }
}
