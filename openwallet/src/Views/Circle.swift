//
//  Circle.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-10-24.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

class Circle: UIView {

    private let color: UIColor

    static let defaultSize: CGFloat = 64.0

    init(color: UIColor) {
        self.color = color
        super.init(frame: CGRect())
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.addEllipse(in: rect)
        ctx.setFillColor(color.cgColor)
        ctx.fillPath()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
