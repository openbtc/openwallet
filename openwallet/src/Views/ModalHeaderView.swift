//
//  ModalHeaderView.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-12-01.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

enum ModalHeaderViewStyle {
    case light
    case dark
}

class ModalHeaderView : UIView {

    //MARK - Public
    var closeCallback: (() -> Void)? {
        didSet { close.tap = closeCallback }
    }

    init(title: String, isFaqHidden: Bool, style: ModalHeaderViewStyle, store: Store) {
        self.title.text = title
        self.style = style
        self.faq = UIButton.buildFaqButton(store: store)
        super.init(frame: .zero)
        faq.isHidden = isFaqHidden
        setupSubviews()
    }

    //MARK - Private
    private let title = UILabel(font: .customBold(size: 17.0))
    private let close = UIButton.close
    private let faq: UIButton
    private let border = UIView()
    private let buttonSize: CGFloat = 44.0
    private let style: ModalHeaderViewStyle

    private func setupSubviews() {
        addSubview(title)
        addSubview(close)
        addSubview(faq)
        addSubview(border)
        close.constrain([
            close.constraint(.leading, toView: self, constant: 0.0),
            close.constraint(.centerY, toView: self, constant: 0.0),
            close.constraint(.height, constant: buttonSize),
            close.constraint(.width, constant: buttonSize) ])
        title.constrain([
            title.constraint(.centerX, toView: self, constant: 0.0),
            title.constraint(.centerY, toView: self, constant: 0.0) ])
        faq.constrain([
            faq.constraint(.trailing, toView: self, constant: 0.0),
            faq.constraint(.centerY, toView: self, constant: 0.0),
            faq.constraint(.height, constant: buttonSize),
            faq.constraint(.width, constant: buttonSize) ])
        border.constrain([
            border.constraint(.height, constant: 1.0) ])
        border.constrainBottomCorners(sidePadding: 0, bottomPadding: 0)

        backgroundColor = .white

        setColors()
    }

    private func setColors() {
        switch style {
        case .light:
            title.textColor = .white
            close.tintColor = .white
            faq.tintColor = .white
        case .dark:
            border.backgroundColor = .secondaryShadow
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
