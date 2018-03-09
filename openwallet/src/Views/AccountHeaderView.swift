//
//  AccountHeaderView.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-16.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

class AccountHeaderView : UIView, GradientDrawable, Subscriber {

    //MARK: - Public
    var balance: UInt64 = 0 {
        didSet { setBalances() }
    }

    var currency: Currency = .bitcoin {
        didSet { setBalances() }
    }

    init(store: Store) {
        self.store = store
        super.init(frame: CGRect())
        setup()
    }

    //MARK: - Private
    private let name = UILabel(font: UIFont.boldSystemFont(ofSize: 17.0))
    private let manage = UIButton(type: .system)
    private let primaryBalance = UpdatingLabel(formatter: Amount.btcFormat)
    private let secondaryBalance = UpdatingLabel(formatter: Amount.localFormat)
    private let info = UILabel()
    private let search = UIButton(type: .system)
    private let currencyTapView = UIView()
    private let store: Store
    //TODO - add equal sign logo

    private var exchangeRate: Rate? {
        didSet { setBalances() }
    }

    private func setup() {
        setData()
        addSubviews()
        addConstraints()
        addShadow()
        addSubscriptions()
    }

    private func setData() {
        store.subscribe(self, selector: { $0.walletState.name != $1.walletState.name }, callback: {
            self.name.text = $0.walletState.name
        })
        name.textColor = .white

        manage.setTitle(S.AccountHeader.manageButtonName, for: .normal)
        manage.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        manage.tintColor = .white
        manage.tap = {
            self.store.perform(action: RootModalActions.Present(modal: .manageWallet))
        }
        primaryBalance.textColor = .white
        primaryBalance.font = UIFont.customBody(size: 26.0)

        secondaryBalance.textColor = .darkText
        secondaryBalance.font = UIFont.customBody(size: 13.0)

        info.textColor = .darkText
        info.font = UIFont.customBody(size: 13.0)

        search.setImage(#imageLiteral(resourceName: "SearchIcon"), for: .normal)
        search.tintColor = .white

        if isTestnet {
            name.textColor = .red
        }
    }

    private func addSubviews() {
        addSubview(name)
        addSubview(manage)
        addSubview(primaryBalance)
        addSubview(secondaryBalance)
        addSubview(info)
        addSubview(search)
        addSubview(currencyTapView)
    }

    private func addConstraints() {
        name.constrain([
            name.constraint(.leading, toView: self, constant: C.padding[2]),
            name.constraint(.top, toView: self, constant: 30.0) ])
        if let manageTitleLabel = manage.titleLabel {
            manage.constrain([
                manage.constraint(.trailing, toView: self, constant: -C.padding[2]),
                manageTitleLabel.firstBaselineAnchor.constraint(equalTo: name.firstBaselineAnchor) ])
        }
        primaryBalance.constrain([
            primaryBalance.constraint(.leading, toView: self, constant: C.padding[2]),
            primaryBalance.constraint(toBottom: name, constant: C.padding[2]) ])
        secondaryBalance.constrain([
            secondaryBalance.constraint(toTrailing: primaryBalance, constant: C.padding[1]/2.0),
            secondaryBalance.constraint(.firstBaseline, toView: primaryBalance, constant: 0.0) ])
        info.constrain([
            info.constraint(.leading, toView: self, constant: C.padding[2]),
            info.constraint(toBottom: secondaryBalance, constant: C.padding[1]/2.0) ])
        search.constrain([
            search.constraint(.trailing, toView: self, constant: -C.padding[2]),
            search.constraint(.bottom, toView: primaryBalance, constant: 0.0),
            search.constraint(.width, constant: 24.0),
            search.constraint(.height, constant: 24.0) ])
        currencyTapView.constrain([
            currencyTapView.leadingAnchor.constraint(equalTo: primaryBalance.leadingAnchor, constant: -C.padding[1]),
            currencyTapView.trailingAnchor.constraint(equalTo: secondaryBalance.trailingAnchor, constant: C.padding[1]),
            currencyTapView.topAnchor.constraint(equalTo: primaryBalance.topAnchor),
            currencyTapView.bottomAnchor.constraint(equalTo: primaryBalance.bottomAnchor) ])

        let gr = UITapGestureRecognizer(target: self, action: #selector(currencySwitchTapped))
        currencyTapView.addGestureRecognizer(gr)
    }

    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 8.0
    }

    private func addSubscriptions() {
        store.subscribe(self,
                        selector: { $0.currency != $1.currency },
                        callback: { self.currency = $0.currency })
        store.subscribe(self,
                        selector: { $0.currentRate != $1.currentRate},
                        callback: { self.exchangeRate = $0.currentRate })
    }

    private func setBalances() {
        guard let rate = exchangeRate else { return }
        let amount = Amount(amount: balance, rate: rate.rate)

        primaryBalance.formatter = currency == .bitcoin ? Amount.btcFormat : Amount.localFormat
        secondaryBalance.formatter = currency == .bitcoin ? Amount.localFormat : Amount.btcFormat

        primaryBalance.setValue(currency == .bitcoin ? amount.bitsAmount : amount.localAmount)
        secondaryBalance.setValue(currency == .bitcoin ? amount.localAmount : amount.bitsAmount)
    }

    override func draw(_ rect: CGRect) {
        drawGradient(rect)
    }

    @objc private func currencySwitchTapped() {
        self.store.perform(action: CurrencyChange.toggle())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
