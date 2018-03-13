//
//  LoginViewController.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-01-19.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import UIKit
import LocalAuthentication

private let touchIdSize: CGFloat = 32.0
private let topControlHeight: CGFloat = 32.0

class LoginViewController : UIViewController {

    //MARK: - Public
    var walletManager: WalletManager? {
        didSet {
            guard let walletManager = walletManager else { return }
            self.pinView = PinView(style: .login, length: walletManager.pinLength)
        }
    }
    var shouldSelfDismiss = false
    init(store: Store, isPresentedForLock: Bool, walletManager: WalletManager? = nil) {
        self.store = store
        self.walletManager = walletManager
        self.isPresentedForLock = isPresentedForLock

        if let walletManager = walletManager {
            self.pinView = PinView(style: .login, length: walletManager.pinLength)
        }
        super.init(nibName: nil, bundle: nil)
    }

    //MARK: - Private
    private let store: Store
    private let backgroundView = LoginBackgroundView()
    private let pinPad = PinPadViewController(style: .clear, keyboardType: .pinPad)
    private let pinViewContainer = UIView()
    private var pinView: PinView?
    private let addressButton = SegmentedButton(title: S.LoginScreen.myAddress, type: .left)
    private let scanButton = SegmentedButton(title: S.LoginScreen.scan, type: .right)
    private let isPresentedForLock: Bool

    private let touchId: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(#imageLiteral(resourceName: "TouchId"), for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = touchIdSize/2.0
        button.layer.masksToBounds = true
        button.accessibilityLabel = S.LoginScreen.touchIdText
        return button
    }()
    private let header = UILabel(font: .systemFont(ofSize: 40.0))
    private let subheader = UILabel(font: .customBody(size: 16.0))
    private var pinPadPottom: NSLayoutConstraint?
    private var topControlTop: NSLayoutConstraint?
    private var unlockTimer: Timer?
    private let pinPadBackground = GradientView()
    private let topControlContainer: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        let separator = UIView()
        view.addSubview(separator)
        separator.backgroundColor = .white
        separator.constrain([
            separator.topAnchor.constraint(equalTo: view.topAnchor),
            separator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            separator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            separator.widthAnchor.constraint(equalToConstant: 1.0) ])
        return view
    }()
    private var hasAttemptedToShowTouchId = false

    override func viewDidLoad() {
        addSubviews()
        addConstraints()
        addTouchIdButton()
        addPinPadCallback()
        if pinView != nil {
            addPinView()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldUseTouchId && !hasAttemptedToShowTouchId && !isPresentedForLock {
            hasAttemptedToShowTouchId = true
            touchIdTapped()
        }
        lockIfNeeded()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unlockTimer?.invalidate()
    }

    private func addPinView() {
        guard let pinView = pinView else { return }
        pinViewContainer.addSubview(pinView)
        view.addSubview(subheader)
        pinView.constrain([
            pinView.bottomAnchor.constraint(equalTo: pinPad.view.topAnchor, constant: -95.0),
            pinView.centerXAnchor.constraint(equalTo: pinViewContainer.centerXAnchor),
            pinView.widthAnchor.constraint(equalToConstant: pinView.width),
            pinView.heightAnchor.constraint(equalToConstant: pinView.itemSize) ])
        subheader.constrain([
            subheader.bottomAnchor.constraint(equalTo: pinView.topAnchor, constant: -C.padding[1]),
            subheader.centerXAnchor.constraint(equalTo: view.centerXAnchor) ])

    }

    private func addSubviews() {
        view.addSubview(backgroundView)
        view.addSubview(pinViewContainer)
        view.addSubview(topControlContainer)
        topControlContainer.addSubview(addressButton)
        topControlContainer.addSubview(scanButton)
        view.addSubview(header)
        view.addSubview(pinPadBackground)
    }

    private func addConstraints() {
        backgroundView.constrain(toSuperviewEdges: nil)
        addChildViewController(pinPad, layout: {
            pinPadPottom = pinPad.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            pinPad.view.constrain([
                pinPad.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                pinPad.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                pinPadPottom,
                pinPad.view.heightAnchor.constraint(equalToConstant: pinPad.height) ])
        })
        pinViewContainer.constrain(toSuperviewEdges: nil)

        topControlTop = topControlContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: C.padding[1] + 20.0)
        topControlContainer.constrain([
            topControlTop,
            topControlContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            topControlContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]),
            topControlContainer.heightAnchor.constraint(equalToConstant: topControlHeight) ])
        addressButton.constrain([
            addressButton.leadingAnchor.constraint(equalTo: topControlContainer.leadingAnchor),
            addressButton.topAnchor.constraint(equalTo: topControlContainer.topAnchor),
            addressButton.trailingAnchor.constraint(equalTo: topControlContainer.centerXAnchor),
            addressButton.bottomAnchor.constraint(equalTo: topControlContainer.bottomAnchor) ])
        scanButton.constrain([
            scanButton.leadingAnchor.constraint(equalTo: topControlContainer.centerXAnchor),
            scanButton.topAnchor.constraint(equalTo: topControlContainer.topAnchor),
            scanButton.trailingAnchor.constraint(equalTo: topControlContainer.trailingAnchor),
            scanButton.bottomAnchor.constraint(equalTo: topControlContainer.bottomAnchor) ])

        header.constrain([
            header.topAnchor.constraint(equalTo: topControlContainer.bottomAnchor, constant: C.padding[6]),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor) ])
        pinPadBackground.constrain([
            pinPadBackground.leadingAnchor.constraint(equalTo: pinPad.view.leadingAnchor),
            pinPadBackground.trailingAnchor.constraint(equalTo: pinPad.view.trailingAnchor),
            pinPadBackground.topAnchor.constraint(equalTo: pinPad.view.topAnchor),
            pinPadBackground.bottomAnchor.constraint(equalTo: pinPad.view.bottomAnchor) ])

        subheader.text = S.LoginScreen.subheader
        header.text = S.LoginScreen.header
        header.textColor = .white

        addressButton.addTarget(self, action: #selector(addressTapped), for: .touchUpInside)
        scanButton.addTarget(self, action: #selector(scanTapped), for: .touchUpInside)
    }

    private func addTouchIdButton() {
        guard shouldUseTouchId else { return }
        view.addSubview(touchId)
        touchId.addTarget(self, action: #selector(touchIdTapped), for: .touchUpInside)
        touchId.constrain([
            touchId.widthAnchor.constraint(equalToConstant: touchIdSize),
            touchId.heightAnchor.constraint(equalToConstant: touchIdSize),
            touchId.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]),
            touchId.bottomAnchor.constraint(equalTo: pinPad.view.topAnchor, constant: -C.padding[2]) ])
    }

    private func addPinPadCallback() {
        pinPad.ouputDidUpdate = { [weak self] pin in
            guard let walletManager = self?.walletManager else { return }
            guard let pinView = self?.pinView else { return }
            let attemptLength = pin.utf8.count
            pinView.fill(attemptLength)
            self?.pinPad.isAppendingDisabled = attemptLength < walletManager.pinLength ? false : true
            if attemptLength == walletManager.pinLength {
                self?.authenticate(pin: pin)
            }
        }
    }

    private func authenticate(pin: String) {
        guard let walletManager = walletManager else { return }
        guard walletManager.authenticate(pin: pin) else { return authenticationFailed() }
        authenticationSucceded()
    }

    private func authenticationSucceded() {
        let label = UILabel(font: subheader.font)
        label.textColor = .white
        label.text = S.LoginScreen.unlocked
        label.alpha = 0.0
        let lock = UIImageView(image: #imageLiteral(resourceName: "unlock"))
        lock.alpha = 0.0

        view.addSubview(label)
        view.addSubview(lock)

        label.constrain([
            label.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -C.padding[1]),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor) ])
        lock.constrain([
            lock.topAnchor.constraint(equalTo: label.bottomAnchor, constant: C.padding[1]),
            lock.centerXAnchor.constraint(equalTo: label.centerXAnchor) ])
        view.layoutIfNeeded()

        UIView.spring(0.6, animations: {
            self.pinPadPottom?.constant = self.pinPad.height
            self.topControlTop?.constant = -100.0
            lock.alpha = 1.0
            label.alpha = 1.0
            self.header.alpha = 0.0
            self.subheader.alpha = 0.0
            self.pinView?.alpha = 0.0
            self.view.layoutIfNeeded()
        }) { completion in
            if self.shouldSelfDismiss {
                self.dismiss(animated: true, completion: nil)
            }
            self.store.perform(action: LoginSuccess())
        }
    }

    private func authenticationFailed() {
        guard let pinView = pinView else { return }
        pinView.shake()
        pinPad.clear()
        DispatchQueue.main.asyncAfter(deadline: .now() + pinView.shakeDuration) { [weak self] in
            pinView.fill(0)
            self?.lockIfNeeded()
        }
    }

    private var shouldUseTouchId: Bool {
        guard let walletManager = self.walletManager else { return false }
        return LAContext.canUseTouchID && !walletManager.pinLoginRequired && store.state.isTouchIdEnabled
    }

    @objc func touchIdTapped() {
        walletManager?.authenticate(touchIDPrompt: S.LoginScreen.touchIdPrompt, completion: { success in
            if success {
                self.authenticationSucceded()
            }
        })
    }

    @objc func addressTapped() {
        store.perform(action: RootModalActions.Present(modal: .loginAddress))
    }

    @objc func scanTapped() {
        store.perform(action: RootModalActions.Present(modal: .loginScan))
    }

    private func lockIfNeeded() {
        if let disabledUntil = walletManager?.walletDisabledUntil {
            let now = Date.timeIntervalSinceReferenceDate
            if disabledUntil > now {
                let disabledUntilDate = Date(timeIntervalSinceReferenceDate: disabledUntil)
                let unlockInterval = disabledUntil - Date.timeIntervalSinceReferenceDate
                let df = DateFormatter()
                df.dateFormat = unlockInterval > C.secondsInDay ? "h:mm a 'on' MMM d, yyy" : "h:mm a"
                subheader.text = "Disabled until: \(df.string(from: disabledUntilDate))"
                pinPad.view.isUserInteractionEnabled = false
                unlockTimer?.invalidate()
                unlockTimer = Timer.scheduledTimer(timeInterval: unlockInterval, target: self, selector: #selector(LoginViewController.unlock), userInfo: nil, repeats: false)
            } else {
                subheader.text = S.LoginScreen.subheader
                pinPad.view.isUserInteractionEnabled = true
            }
        }
    }

    @objc private func unlock() {
        subheader.pushNewText(S.LoginScreen.subheader)
        pinPad.view.isUserInteractionEnabled = true
        unlockTimer = nil
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
