//
//  StartFlowController.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-10-22.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

class StartFlowController: Subscriber {

    private let store: Store
    private let rootViewController: UIViewController
    private var startNavigationController: UINavigationController?

    init(store: Store, rootViewController: UIViewController) {
        self.store = store
        self.rootViewController = rootViewController
        addStartSubscription()
        addPinCreationSubscription()
    }

    private func addStartSubscription() {
        store.subscribe(self, subscription: Subscription(
            selector: { $0.isStartFlowVisible != $1.isStartFlowVisible },
            callback: {
                if $0.isStartFlowVisible {
                    self.presentStartFlow()
                } else {
                    self.dismissStartFlow()
                }
            }))
    }

    private func addPinCreationSubscription() {
        store.subscribe(self, subscription: Subscription(
            selector: { $0.pinCreationStep != $1.pinCreationStep },
            callback: {
                switch $0.pinCreationStep {
                    case .start:
                        self.pushPinCreationViewController()
                    case .confirm:
                        print("confirm")
                    case .save:
                        print("save")
                    case .none:
                        print("none")
                }
        }))
    }

    private func presentStartFlow() {
        let startViewController = StartViewController(store: store)
        startNavigationController = UINavigationController(rootViewController: startViewController)
        if let startFlow = startNavigationController {
            startFlow.setNavigationBarHidden(true, animated: false)
            rootViewController.present(startFlow, animated: false, completion: nil)
        }
    }

    private func dismissStartFlow() {
        startNavigationController?.dismiss(animated: true) { [weak self] in
            self?.startNavigationController = nil
        }
    }

    private func pushPinCreationViewController() {
        let pinCreationViewController = PinCreationViewController()
        pinCreationViewController.title = "Create New Wallet"
        
        //Access the view as we want to trigger viewDidLoad before it gets pushed.
        //This makes the keyboard slide in from the right.
        let _ = pinCreationViewController.view
        startNavigationController?.setNavigationBarHidden(false, animated: false)
        startNavigationController?.pushViewController(pinCreationViewController, animated: true)
    }
}
