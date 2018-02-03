//
//  PinPadCell.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-12-15.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

class PinPadCell : UICollectionViewCell {

    var text: String? {
        didSet {
            if text == deleteKeyIdentifier {
                imageView.image = #imageLiteral(resourceName: "Delete")
                label.text = ""
            } else {
                imageView.image = nil
                label.text = text
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            setColors()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    internal let label = UILabel(font: .customBody(size: 26.0))
    private let imageView = UIImageView()

    private func setup() {
        setColors()
        label.textAlignment = .center
        addSubview(label)
        addSubview(imageView)
        label.constrain(toSuperviewEdges: nil)
        imageView.constrain(toSuperviewEdges: nil)
        imageView.contentMode = .center
    }

    func setColors() {}

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
