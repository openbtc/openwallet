//
//  InViewAlert.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-12-03.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

enum InViewAlertType {
    case primary
    case secondary
}

class InViewAlert: UIView {

    var heightConstraint: NSLayoutConstraint?
    var expanded = false
    var collapsedHeight: CGFloat = 0.0
    static let height: CGFloat = 80.0

    init(type: InViewAlertType) {
        self.type = type
        super.init(frame: .zero)
        setupSubViews()
    }

    func toggle() {
        heightConstraint?.constant = expanded ? collapsedHeight : InViewAlert.height
    }

    var heightDifference: CGFloat {
        return InViewAlert.height - collapsedHeight
    }

    private let type: InViewAlertType
    private let arrowHeight: CGFloat = 10.0
    private let arrowWidth: CGFloat = 16.0

    private func setupSubViews(){
        contentMode = .redraw
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        //When collapsed, this view is used as padding.
        //This is why we don't want it drawn when it's small.
        if collapsedHeight > 0.0 {
            guard rect.height > collapsedHeight else { return }
        }
        let background = UIBezierPath(rect: rect.offsetBy(dx: 0, dy: arrowHeight))
        fillColor.setFill()
        background.fill()

        let context = UIGraphicsGetCurrentContext()

        let triangle = CGMutablePath()
        triangle.move(to: CGPoint(x: rect.width/2.0 - arrowWidth/2.0 + 0.5, y: arrowHeight + 0.5))
        triangle.addLine(to: CGPoint(x: rect.width/2.0 + 0.5, y: 0.5))
        triangle.addLine(to: CGPoint(x: rect.width/2.0 + arrowWidth/2.0 + 0.5, y: arrowHeight + 0.5))
        triangle.closeSubpath()
        context?.setLineJoin(.miter)
        context?.setFillColor(fillColor.cgColor)
        context?.addPath(triangle)
        context?.fillPath()

        //Add Gray border for secondary style
        if type == .secondary {
            let topBorder = CGMutablePath()
            topBorder.move(to: CGPoint(x: 0, y: arrowHeight))
            topBorder.addLine(to: CGPoint(x: rect.width/2.0 - arrowWidth/2.0 + 0.5, y: arrowHeight + 0.5))
            topBorder.addLine(to: CGPoint(x: rect.width/2.0 + 0.5, y: 0.5))
            topBorder.addLine(to: CGPoint(x: rect.width/2.0 + arrowWidth/2.0 + 0.5, y: arrowHeight + 0.5))
            topBorder.addLine(to: CGPoint(x: rect.width + 0.5, y: arrowHeight + 0.5))
            context?.setLineWidth(1.0)
            context?.setStrokeColor(UIColor.secondaryShadow.cgColor)
            context?.addPath(topBorder)
            context?.strokePath()
        }
    }

    private var fillColor: UIColor {
        switch type {
            case .primary:
                return .primaryButton
            case .secondary:
                return .grayBackgroundTint
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
}
