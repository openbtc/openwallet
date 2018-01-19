//
//  AccountFooterView.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-16.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

class AccountFooterView: UIView {

    var sendCallback: (() -> Void)?
    var receiveCallback: (() -> Void)?
    var menuCallback: (() -> Void)?

    override init (frame : CGRect) {
        super.init(frame : frame)
        setupSubViews()
    }

    convenience init () {
        self.init(frame: .zero)
    }

    func setupSubViews(){

        let backgroundView = UITabBar()
        addSubview(backgroundView)
        backgroundView.constrain(toSuperviewEdges: nil)

        let send = UIButton.vertical(title: "SEND", image: #imageLiteral(resourceName: "SendButtonIcon"))
        send.tintColor = .grayTextTint
        send.addTarget(self, action: #selector(AccountFooterView.send), for: .touchUpInside)

        let receive = UIButton.vertical(title: "RECEIVE", image: #imageLiteral(resourceName: "ReceiveButtonIcon"))
        receive.tintColor = .grayTextTint
        receive.addTarget(self, action: #selector(AccountFooterView.receive), for: .touchUpInside)

        let menu = UIButton.vertical(title: "MENU", image: #imageLiteral(resourceName: "MenuButtonIcon"))
        menu.tintColor = .grayTextTint
        menu.addTarget(self, action: #selector(AccountFooterView.menu), for: .touchUpInside)

        addSubview(send)
        addSubview(receive)
        addSubview(menu)

        send.constrain([
                send.constraint(.leading, toView: self, constant: 0.0),
                send.constraint(.top, toView: self, constant: 0.0),
                send.constraint(.bottom, toView: self, constant: 0.0),
                NSLayoutConstraint(item: send, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0/3.0, constant: 0.0)
            ])
        receive.constrain([
                NSLayoutConstraint(item: receive, attribute: .leading, relatedBy: .equal, toItem: send, attribute: .trailing, multiplier: 1.0, constant: 0.0),
                receive.constraint(.top, toView: self, constant: 0.0),
                receive.constraint(.bottom, toView: self, constant: 0.0),
                NSLayoutConstraint(item: receive, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0/3.0, constant: 1.0)
            ])
        menu.constrain([
                NSLayoutConstraint(item: menu, attribute: .leading, relatedBy: .equal, toItem: receive, attribute: .trailing, multiplier: 1.0, constant: 1.0),
                menu.constraint(.top, toView: self, constant: 0.0),
                menu.constraint(.bottom, toView: self, constant: 0.0),
                NSLayoutConstraint(item: menu, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0/3.0, constant: 1.0)
            ])
    }

    @objc private func send() { sendCallback?() }
    @objc private func receive() { receiveCallback?() }
    @objc private func menu() { menuCallback?() }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
}
