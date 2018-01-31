//
//  ShadowButton.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-15.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

enum ButtonType {
    case primary
    case secondary
    case tertiary
}

class ShadowButton: UIControl {

    init(title: String, type: ButtonType) {
        self.title = title
        self.type = type
        super.init(frame: CGRect.zero)
        accessibilityLabel = title
        setupViews()
    }

    init(title: String, type: ButtonType, image: UIImage) {
        self.title = title
        self.type = type
        self.image = image
        super.init(frame: CGRect.zero)
        accessibilityLabel = title
        setupViews()
    }

    var isToggleable = false
    private let title: String
    private let type: ButtonType
    private let container = UIView()
    private let shadowView = UIView()
    private let label = UILabel()
    private let shadowYOffset: CGFloat = 4.0
    private let cornerRadius: CGFloat = 4.0
    private var image: UIImage?
    private var imageView: UIImageView?

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.04, animations: {
                    let shrink = CATransform3DMakeScale(0.97, 0.97, 1.0)
                    let translate = CATransform3DTranslate(shrink, 0, 4.0, 0)
                    self.container.layer.transform = translate
                })
            } else {
                UIView.animate(withDuration: 0.04, animations: {
                    self.container.transform = CGAffineTransform.identity
                })
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            guard isToggleable else { return }
            if type == .tertiary {
                if isSelected {
                    container.layer.borderColor = UIColor.primaryButton.cgColor
                    imageView?.tintColor = .primaryButton
                    label.textColor = .primaryButton
                } else {
                    setColors()
                }
            }
        }
    }

    private func setupViews() {
        addShadowView()
        addContent()
        setColors()
        addTarget(self, action: #selector(ShadowButton.touchUpInside), for: .touchUpInside)
    }

    private func addShadowView() {
        addSubview(shadowView)
        shadowView.constrain([
                NSLayoutConstraint(item: shadowView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.5, constant: 0.0),
                shadowView.constraint(.bottom, toView: self),
                shadowView.constraint(.centerX, toView: self),
                NSLayoutConstraint(item: shadowView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.8, constant: 0.0),
            ])
        shadowView.layer.cornerRadius = 4.0
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowView.backgroundColor = .white
        shadowView.isUserInteractionEnabled = false
    }

    private func addContent() {
        addSubview(container)
        container.backgroundColor = .primaryButton
        container.layer.cornerRadius = cornerRadius
        container.isUserInteractionEnabled = false
        container.constrain(toSuperviewEdges: nil)

        label.text = title
        label.textColor = .white
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.font = UIFont.customMedium(size: 16.0)

        configureContentType()

    }

    private func configureContentType() {
        if let icon = image {
            setupImageOption(icon: icon)
        } else {
            setupLabelOnly()
        }
    }

    private func setupImageOption(icon: UIImage) {
        let content = UIView()
        let iconImageView = UIImageView(image: icon.withRenderingMode(.alwaysTemplate))
        iconImageView.contentMode = .scaleAspectFit
        container.addSubview(content)
        content.addSubview(label)
        content.addSubview(iconImageView)
        content.constrainToCenter()

        iconImageView.constrainLeadingCorners()
        label.constrainTrailingCorners()

        iconImageView.constrain([
                iconImageView.constraint(toLeading: label, constant: -C.padding[1])
            ])
        imageView = iconImageView
    }

    private func setupLabelOnly() {
        container.addSubview(label)
        label.constrain(toSuperviewEdges: nil)
    }

    private func setColors() {
        switch type {
            case .primary:
                container.backgroundColor = .primaryButton
                label.textColor = .primaryText
                shadowView.layer.shadowColor = UIColor.black.cgColor
                shadowView.layer.shadowOpacity = 0.3
                imageView?.tintColor = .white
            case .secondary:
                container.backgroundColor = .secondaryButton
                label.textColor = .darkText
                container.layer.borderColor = UIColor.secondaryBorder.cgColor
                container.layer.borderWidth = 1.0
                shadowView.layer.shadowColor = UIColor.secondaryShadow.cgColor
                shadowView.layer.shadowOpacity = 1.0
                imageView?.tintColor = .darkText
            case .tertiary:
                container.backgroundColor = .secondaryButton
                label.textColor = .grayTextTint
                container.layer.borderColor = UIColor.secondaryBorder.cgColor
                container.layer.borderWidth = 1.0
                shadowView.layer.shadowColor = UIColor.secondaryShadow.cgColor
                shadowView.layer.shadowOpacity = 1.0
                imageView?.tintColor = .grayTextTint
        }
    }

    @objc private func touchUpInside() {
        isSelected = !isSelected
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
