//
//  UIViewController+BRWAdditions.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-10-21.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

extension UIViewController {
    convenience init(tabBarItem: UITabBarItem) {
        self.init(nibName: nil, bundle: nil)
        self.tabBarItem = tabBarItem
    }
}
