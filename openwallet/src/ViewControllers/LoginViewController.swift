//
//  LoginViewController.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-01-19.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController {

    //MARK: - Public
    init(store: Store, walletManager: WalletManager) {
        self.store = store
        self.walletManager = walletManager
        super.init(nibName: nil, bundle: nil)
    }

    //MARK: - Private
    private let store: Store
    private let walletManager: WalletManager
    private let backgroundView = LoginBackgroundView()
    private let textField = UITextField()
    private let pinPad = PinPadViewController(style: .clear, keyboardType: .pinPad)
    private let pinView = PinView(style: .white)
    private let topControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [S.LoginScreen.myAddress, S.LoginScreen.scan])
        control.tintColor = .white
        control.isMomentary = true
        control.setTitleTextAttributes([NSFontAttributeName: UIFont.customMedium(size: 13.0)], for: .normal)
        return control
    }()
    private let touchId: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(#imageLiteral(resourceName: "TouchId"), for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 22.0
        button.layer.masksToBounds = true
        button.accessibilityLabel = S.LoginScreen.touchIdText
        return button
    }()
    override func viewDidLoad() {
        view.addSubview(backgroundView)
        backgroundView.constrain(toSuperviewEdges: nil)

        addChildViewController(pinPad, layout: {
            pinPad.view.constrainBottomCorners(sidePadding: 0.0, bottomPadding: 0.0)
            pinPad.view.constrain([
                pinPad.view.heightAnchor.constraint(equalToConstant: PinPadViewController.height) ])
        })

        backgroundView.addSubview(pinView)
        pinView.constrain([
            pinView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            pinView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            pinView.widthAnchor.constraint(equalToConstant: pinView.defaultWidth + C.padding[1]*6),
            pinView.heightAnchor.constraint(equalToConstant: pinView.defaultPinSize) ])

        view.addSubview(topControl)
        topControl.addTarget(self, action: #selector(topControlChanged(control:)), for: .valueChanged)
        topControl.constrainTopCorners(sidePadding: C.padding[2], topPadding: C.padding[2], topLayoutGuide: topLayoutGuide)
        topControl.constrain([
            topControl.heightAnchor.constraint(equalToConstant: 32.0) ])

        view.addSubview(touchId)
        touchId.addTarget(self, action: #selector(touchIdTapped), for: .touchUpInside)
        touchId.constrain([
            touchId.widthAnchor.constraint(equalToConstant: 44.0),
            touchId.heightAnchor.constraint(equalToConstant: 44.0),
            touchId.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]),
            touchId.bottomAnchor.constraint(equalTo: pinPad.view.topAnchor, constant: -C.padding[2]) ])

        pinPad.ouputDidUpdate = { pin in
            let length = pin.lengthOfBytes(using: .utf8)
            self.pinView.fill(length)
            self.pinPad.isAppendingDisabled = length < 6 ? false : true
            if length == 6 {
                self.authenticate(pin: pin)
            }
        }
    }

    private func authenticate(pin: String) {
        let isAuthenticated = self.walletManager.authenticate(pin: pin)
        if isAuthenticated {
            store.perform(action: LoginSuccess())
        } else {
            self.pinView.shake()
            self.pinPad.clear()
            DispatchQueue.main.asyncAfter(deadline: .now() + pinView.shakeDuration) { [weak self] in
                self?.pinView.fill(0)
            }
        }
    }

    @objc private func topControlChanged(control: UISegmentedControl) {
        if control.selectedSegmentIndex == 0 {
            addressTapped()
        } else if control.selectedSegmentIndex == 1 {
            scanTapped()
        }
    }

    private func addressTapped() {

    }

    private func scanTapped() {

    }

    @objc func touchIdTapped() {

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
