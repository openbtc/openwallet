//
//  UINavigationController+BRAdditions.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-29.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

extension UINavigationController {
    func setClearNavbar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }
}
