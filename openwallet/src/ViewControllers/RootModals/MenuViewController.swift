//
//  MenuViewController.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-24.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    private let buttonHeight: CGFloat = 78.0
    private let buttons: [MenuButton] = {
        let types: [MenuButtonType] = [.profile, .security, .support, .settings, .lock]
        return types.map { MenuButton(type: $0) }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        buttons.forEach { view.addSubview($0) }

        var previousButton: UIView?
        buttons.forEach { button in

            var topConstraint: NSLayoutConstraint?
            if let viewAbove = previousButton {
                topConstraint = button.constraint(toBottom: viewAbove, constant: 0.0)
            } else {
                topConstraint = button.constraint(.top, toView: view, constant: 0.0)
            }

            button.constrain([
                    topConstraint,
                    button.constraint(.leading, toView: view, constant: 0.0),
                    button.constraint(.trailing, toView: view, constant: 0.0),
                    button.constraint(.height, constant: buttonHeight)
                ])
            previousButton = button
        }
    }
}
