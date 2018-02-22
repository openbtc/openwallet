//
//  File.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-30.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

class ModalViewController : UIViewController {

    //MARK: - Public
    var childViewController: UIViewController

    init<T: UIViewController>(childViewController: T) where T: ModalDisplayable {
        self.childViewController = childViewController
        self.modalInfo = childViewController
        self.header = ModalHeaderView(title: modalInfo.modalTitle, isFaqHidden: modalInfo.isFaqHidden, style: .dark)

        super.init(nibName: nil, bundle: nil)
    }

    //MARK: - Private
    private let modalInfo: ModalDisplayable
    private let headerHeight: CGFloat = 49.0
    private let header: ModalHeaderView

    override func viewDidLoad() {
        view.backgroundColor = .clear
        view.addSubview(header)

        header.closeCallback = {
            if let delegate = self.transitioningDelegate as? ModalTransitionDelegate {
                delegate.reset()
            }
            self.dismiss(animated: true, completion: {})
        }
        
        addTopCorners()

        addChildViewController(childViewController, layout: {
            childViewController.view?.constrain([
                childViewController.view?.constraint(.leading, toView: view, constant: 0.0),
                childViewController.view?.constraint(.trailing, toView: view, constant: 0.0),
                childViewController.view?.constraint(.bottom, toView: view, constant: 0.0) ])
        })

        header.constrain([
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.bottomAnchor.constraint(equalTo: childViewController.view.topAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: headerHeight)])

        if var modalPresentable = childViewController as? ModalPresentable {
            modalPresentable.parentView = view
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowRadius = 4.0
        view.layer.shadowOffset = .zero
    }

    //Even though the status bar is hidden for this view,
    //it still needs to be set to light as it will temporarily
    //transition to black when this view gets presented
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private func addTopCorners() {
        let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 6.0, height: 6.0)).cgPath
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        header.layer.mask = maskLayer
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
