//
//  StartViewController.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-10-22.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    private let circle =    Circle(color: .brand)
    private let brand =     UILabel()
    private let create =    ShadowButton(title: NSLocalizedString("Create New Wallet", comment: "button label"), type: .primary)
    private let recover =   ShadowButton(title: NSLocalizedString("Recover Wallet", comment: "button label"), type: .secondary)

    private let store: Store

    init(store: Store) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        view.backgroundColor = .white
        setData()
        addSubviews()
        addConstraints()
        addButtonActions()
    }

    private func setData() {
        brand.text = "Bread"
        brand.font = UIFont.customBold(size: 26.0)
    }

    private func addSubviews() {
        view.addSubview(circle)
        view.addSubview(brand)
        view.addSubview(create)
        view.addSubview(recover)
    }

    private func addConstraints() {
        circle.constrain([
                circle.constraint(.centerX, toView: view, constant: nil),
                circle.constraint(.top, toView: view, constant: 120.0),
                circle.constraint(.width, constant: Circle.defaultSize),
                circle.constraint(.height, constant: Circle.defaultSize)
            ])
        brand.constrain([
                brand.constraint(.centerX, toView: circle, constant: nil),
                brand.constraint(toBottom: circle, constant: C.padding[1])
            ])
        recover.constrain([
                recover.constraint(.leading, toView: view, constant: C.padding[2]),
                recover.constraint(.bottom, toView: view, constant: -C.padding[3]),
                recover.constraint(.trailing, toView: view, constant: -C.padding[2]),
                recover.constraint(.height, constant: C.Sizes.buttonHeight)
            ])
        create.constrain([
                create.constraint(toTop: recover, constant: -C.padding[2]),
                create.constraint(.centerX, toView: recover, constant: nil),
                create.constraint(.width, toView: recover, constant: nil),
                create.constraint(.height, constant: C.Sizes.buttonHeight)
            ])
    }

    private func addButtonActions() {
        create.addTarget(self, action: #selector(createWallet), for: .touchUpInside)
        recover.addTarget(self, action: #selector(recoverWallet), for: .touchUpInside)
    }

    @objc private func recoverWallet() {
        //TODO - implement recover wallet flow
    }

    @objc private func createWallet() {
        store.perform(action: PinCreation.Start())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
