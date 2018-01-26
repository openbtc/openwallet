//
//  SendCell.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-12-01.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

class SendCell: UIView {

    init(label: String) {
        super.init(frame: .zero)
        self.label.text = label
        setupViews()
    }

    var content: String? {
        didSet {
            contentLabel.text = content
        }
    }

    let accessoryView = UIView()

    private let label = UILabel(font: .customBody(size: 16.0))
    private let contentLabel = UILabel(font: .customBody(size: 14.0))
    private let border = UIView()

    private func setupViews() {
        addSubview(label)
        addSubview(contentLabel)
        addSubview(accessoryView)
        addSubview(border)
        label.constrain([
                label.constraint(.centerY, toView: self),
                label.constraint(.leading, toView: self, constant: C.padding[2])
            ])
        contentLabel.constrain([
                contentLabel.constraint(.leading, toView: label),
                contentLabel.constraint(toBottom: label, constant: 0.0),
                contentLabel.constraint(toLeading: accessoryView, constant: -C.padding[2])
            ])
        accessoryView.constrain([
                accessoryView.constraint(.top, toView: self),
                accessoryView.constraint(.trailing, toView: self),
                accessoryView.constraint(.bottom, toView: self)
            ])
        border.constrainBottomCorners(height: 1.0)

        border.backgroundColor = .secondaryShadow
        label.textColor = .grayTextTint
        contentLabel.lineBreakMode = .byTruncatingMiddle
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
