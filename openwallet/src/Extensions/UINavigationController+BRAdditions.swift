//
//  UINavigationController+BRAdditions.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-29.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

extension UINavigationController {

    func setDefaultStyle() {
        setClearNavbar()
        setBlackBackArrow()
    }

    func setClearNavbar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }

    func setBlackBackArrow() {
        let image = #imageLiteral(resourceName: "Back")
        let renderedImage = image.withRenderingMode(.alwaysOriginal)
        navigationBar.backIndicatorImage = renderedImage
        navigationBar.backIndicatorTransitionMaskImage = renderedImage
    }

    func setTintableBackArrow() {
        navigationBar.backIndicatorImage = #imageLiteral(resourceName: "Back")
        navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "Back")
    }
}
