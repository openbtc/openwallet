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
    private let alertHeight: CGFloat = 260.0

    init(store: Store, window: UIWindow) {
        self.store = store
        self.window = window
        addSubscriptions()
    }

    private func addSubscriptions() {
        store.subscribe(self, subscription: Subscription(
            selector: { _,_ in true },
            callback: { state in
                if case .save(_) = state.pinCreationStep {
                    self.presentAlert(.pinSet) {
                        self.store.perform(action: PaperPhrase.Start())
                    }
                }

                if case .confirmed(_) = state.paperPhraseStep {
                    self.presentAlert(.paperKeySet) {
                        self.store.perform(action: HideStartFlow())
                    }
                }
        }))
    }

    private func presentAlert(_ type: AlertType, completion: @escaping ()->Void) {

        let alertView = AlertView(type: type)
        let size = activeWindow.bounds.size
        activeWindow.addSubview(alertView)

        let topConstraint = alertView.constraint(.top, toView: activeWindow, constant: size.height)
        alertView.constrain([
                alertView.constraint(.width, constant: size.width),
                alertView.constraint(.height, constant: alertHeight + 25.0),
                alertView.constraint(.leading, toView: activeWindow, constant: nil),
                topConstraint
            ])
        activeWindow.layoutIfNeeded()
        if #available(iOS 10.0, *) {

            let presentAnimator = UIViewPropertyAnimator.springAnimation {
                topConstraint?.constant = size.height - self.alertHeight
                self.activeWindow.layoutIfNeeded()
            }

            let dismissAnimator = UIViewPropertyAnimator.springAnimation {
                topConstraint?.constant = size.height
                self.activeWindow.layoutIfNeeded()
            }

            presentAnimator.addCompletion { _ in
                alertView.animate()
                dismissAnimator.startAnimation(afterDelay: 2.0)
            }

            dismissAnimator.addCompletion { _ in
                completion()
                alertView.removeFromSuperview()
            }

            presentAnimator.startAnimation()
        }
    }

    //TODO - This is a total hack to grab the window that keyboard is in
    //After pin creation, the alert view needs to be presented over the keyboard
    private var activeWindow: UIWindow {
        let windowsCount = UIApplication.shared.windows.count
        if let keyboardWindow = UIApplication.shared.windows.last, windowsCount > 1 {
            return keyboardWindow
        }
        return window
    }

}
