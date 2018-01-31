//
//  UIView+InitAdditions.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-12-19.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

extension UIView {
    convenience init(color: UIColor) {
        self.init(frame: .zero)
        backgroundColor = color
    }
}
