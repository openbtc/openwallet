//
//  SecurityCenterViewController.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-02-14.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import UIKit

class SecurityCenterHeader : UIView, GradientDrawable {
    override func draw(_ rect: CGRect) {
        drawGradient(rect)
    }
}

class SecurityCenterViewController : UIViewController {

    override func viewDidLoad() {
        view.backgroundColor = .white
        view.addSubview(headerBackground)
        view.addSubview(header)
        headerBackground.constrainTopCorners(sidePadding: 0.0, topPadding: 0.0)
        headerBackground.constrain([
            headerBackground.heightAnchor.constraint(equalToConstant: 222.0) ])
        header.constrainTopCorners(sidePadding: 0.0, topPadding: 0.0, topLayoutGuide: topLayoutGuide)
        header.constrain([
            header.heightAnchor.constraint(equalToConstant: C.Sizes.headerHeight) ])
        header.closeCallback = {
            self.dismiss(animated: true, completion: nil)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private let headerBackground = SecurityCenterHeader()
    private let header = ModalHeaderView(title: S.SecurityCenter.title, isFaqHidden: false)
}
