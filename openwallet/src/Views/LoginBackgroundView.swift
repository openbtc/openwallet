//
//  LoginBackgroundView.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-01-19.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import UIKit

class LoginBackgroundView : UIView, GradientDrawable {

    init() {
        super.init(frame: .zero)
    }

    override func draw(_ rect: CGRect) {
        drawGradient(rect)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
