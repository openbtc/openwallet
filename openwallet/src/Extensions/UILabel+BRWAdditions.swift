//
//  UILabel+BRWAdditions.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-10-26.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

extension UILabel {

    static func makeWrappingLabel(font: UIFont) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        return label
    }

}
