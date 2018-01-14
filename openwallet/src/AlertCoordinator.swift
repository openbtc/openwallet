//
//  AlertCoordinator.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-10-25.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

class AlertCoordinator: Subscriber {

    private let store: Store
    private let window: UIWindow
    private let simpleAlertView: UIView = {
        let view = UIView()
        view.backgroundColor = .brand
        view.layer.cornerRadius = 6.0
        return view
    }()
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.customBold(size: 14.0)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    private let alertHeight: CGFloat = 260.0

    init(store: Store, window: UIWindow) {
        self.store = store
        self.window = window

        setupAlertView()
        addSubscriptions()
    }

    private func setupAlertView() {
        simpleAlertView.addSubview(label)
        label.constrainTopCorners(sidePadding: Constants.Padding.double, topPadding: Constants.Padding.quad)
    }

    private func addSubscriptions() {
        store.subscribe(self, subscription: Subscription(
            selector: { _,_ in true },
            callback: { state in
                if case .save(_) = state.pinCreationStep {
                    self.presentAlert("Pin Set") {
                        self.store.perform(action: PaperPhrase.Start())
                    }
                }

                if case .confirmed(_) = state.paperPhraseStep {
                    self.presentAlert("Paper Key Set") {
                        self.store.perform(action: HideStartFlow())
                    }
                }
        }))
    }

    private func presentAlert(_ text: String, completion: @escaping ()->Void) {

        label.text = text

        //TODO - This is a total hack to grab the window that keyboard is in
        //After pin creation, the alert view needs to be presented over the keyboard
        let windowsCount = UIApplication.shared.windows.count
        let keyboardWindow = UIApplication.shared.windows[windowsCount - 1]
        let size = keyboardWindow.bounds.size

        keyboardWindow.addSubview(simpleAlertView)

        let topConstraint = simpleAlertView.constraint(.top, toView: keyboardWindow, constant: size.height)
        simpleAlertView.constrain([
                simpleAlertView.constraint(.width, constant: size.width),
                simpleAlertView.constraint(.height, constant: alertHeight + 25.0),
                simpleAlertView.constraint(.leading, toView: keyboardWindow, constant: nil),
                topConstraint
            ])
        keyboardWindow.layoutIfNeeded()
        if #available(iOS 10.0, *) {

            let presentAnimator = UIViewPropertyAnimator.springAnimation {
                topConstraint.constant = size.height - self.alertHeight
                keyboardWindow.layoutIfNeeded()
            }

            let dismissAnimator = UIViewPropertyAnimator.springAnimation {
                topConstraint.constant = size.height
                keyboardWindow.layoutIfNeeded()
            }

            presentAnimator.addCompletion { _ in
                dismissAnimator.startAnimation(afterDelay: 2.0)
            }

            dismissAnimator.addCompletion { _ in
                completion()
            }

            presentAnimator.startAnimation()
        }
    }

}
