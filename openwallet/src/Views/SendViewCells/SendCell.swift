//
//  SendCell.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-12-01.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

class SendCell : UIView {

    static let defaultHeight: CGFloat = 72.0

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    let accessoryView = UIView()

    let border = UIView()

    private func setupViews() {
        addSubview(accessoryView)
        addSubview(border)
        accessoryView.constrain([
            accessoryView.constraint(.top, toView: self),
            accessoryView.constraint(.trailing, toView: self),
            accessoryView.heightAnchor.constraint(equalToConstant: SendCell.defaultHeight) ])
        border.constrainBottomCorners(height: 1.0)
        border.backgroundColor = .secondaryShadow
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

