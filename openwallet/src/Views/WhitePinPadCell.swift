//
//  WhitePinPadCell.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-01-23.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import UIKit

class WhitePinPadCell : PinPadCell {

    override func setColors() {
        if isHighlighted {
            label.backgroundColor = .secondaryShadow
            label.textColor = .darkText
        } else {
            label.backgroundColor = .white
            label.textColor = .grayTextTint
        }
    }

}
