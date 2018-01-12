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
    private let create =    UIButton.makeSolidButton(title: "Create New Wallet")
    private let recover =   UIButton.makeOutlineButton(title: "Recover Wallet")

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
    }

    func setData() {
        brand.text = "Bread"
    }

    func addSubviews() {
        view.addSubview(circle)
        view.addSubview(brand)
        view.addSubview(create)
        view.addSubview(recover)
    }

    func addConstraints() {
        circle.constrain([
                circle.constraint(.centerX, toView: view, constant: nil),
                circle.constraint(.top, toView: view, constant: 120.0),
                circle.constraint(.width, constant: Circle.defaultSize),
                circle.constraint(.height, constant: Circle.defaultSize)
            ])
        brand.constrain([
                brand.constraint(.centerX, toView: circle, constant: nil),
                brand.constraint(toBottom: circle, constant: Constants.Padding.single)
            ])
        recover.constrain([
                recover.constraint(.leading, toView: view, constant: Constants.Padding.double),
                recover.constraint(.bottom, toView: view, constant: -Constants.Padding.triple),
                recover.constraint(.trailing, toView: view, constant: -Constants.Padding.double),
                recover.constraint(.height, constant: Constants.Sizes.buttonHeight)
            ])
        create.constrain([
                create.constraint(toTop: recover, constant: -Constants.Padding.double),
                create.constraint(.centerX, toView: recover, constant: nil),
                create.constraint(.width, toView: recover, constant: nil),
                create.constraint(.height, constant: Constants.Sizes.buttonHeight)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
