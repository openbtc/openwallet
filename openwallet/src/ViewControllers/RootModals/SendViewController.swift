//
//  SendViewController.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-30.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

private let toLabel = NSLocalizedString("To", comment: "Send money to label")
private let amountLabel = NSLocalizedString("Amount", comment: "Send money amount label")
private let descriptionLabel = NSLocalizedString("What's this for?", comment: "Description for sending money label")
private let sendLabel = NSLocalizedString("Send", comment: "Send button label")
private let pasteLabel = NSLocalizedString("Paste", comment: "Paste button label")
private let scanLabel = NSLocalizedString("Scan", comment: "Scan button label")
private let currencyLabel = NSLocalizedString("USD \u{25BC}", comment: "Currency Button label")

class SendViewController: UIViewController {

    fileprivate let cellHeight: CGFloat = 72.0
    fileprivate let verticalButtonPadding: CGFloat = 32.0
    private let buttonSize = CGSize(width: 52.0, height: 32.0)

    private let to = SendCell(label: toLabel)
    private let amount = SendCell(label: amountLabel)
    private let descriptionCell = SendCell(label: descriptionLabel)
    private let send = ShadowButton(title: sendLabel, type: .primary, image: #imageLiteral(resourceName: "TouchId"))
    private let paste = ShadowButton(title: pasteLabel, type: .tertiary)
    private let scan = ShadowButton(title: scanLabel, type: .tertiary)
    private let currency = ShadowButton(title: currencyLabel, type: .tertiary)

    override func viewDidLoad() {
        view.addSubview(to)
        view.addSubview(amount)
        view.addSubview(descriptionCell)
        view.addSubview(send)
        to.addSubview(paste)
        to.addSubview(scan)
        amount.addSubview(currency)

        to.constrainTopCorners(height: cellHeight)
        amount.pinToBottom(to: to, height: cellHeight)
        descriptionCell.pinToBottom(to: amount, height: cellHeight)
        send.constrain([
                send.constraint(.leading, toView: view, constant: C.padding[2]),
                send.constraint(.trailing, toView: view, constant: -C.padding[2]),
                send.constraint(toBottom: descriptionCell, constant: verticalButtonPadding),
                send.constraint(.height, constant: C.Sizes.buttonHeight)
            ])
        scan.constrain([
                scan.constraint(.centerY, toView: to),
                scan.constraint(.trailing, toView: to, constant: -C.padding[2]),
                scan.constraint(.height, constant: buttonSize.height),
                scan.constraint(.width, constant: buttonSize.width)
            ])
        paste.constrain([
                paste.constraint(.centerY, toView: to),
                paste.constraint(toLeading: scan, constant: -C.padding[1]),
                paste.constraint(.height, constant: buttonSize.height),
                paste.constraint(.width, constant: buttonSize.width)
            ])
        currency.constrain([
                currency.constraint(.centerY, toView: amount),
                currency.constraint(.trailing, toView: amount, constant: -C.padding[2]),
                currency.constraint(.height, constant: buttonSize.height),
                currency.constraint(.width, constant: 64.0)
            ])
    }

}

extension SendViewController: ModalDisplayable {
    var modalTitle: String {
        return NSLocalizedString("Send Money", comment: "Send modal title")
    }

    var modalSize: CGSize {
        return CGSize(width: view.frame.width, height: cellHeight*3 + verticalButtonPadding*2 + C.Sizes.buttonHeight)
    }

    var isFaqHidden: Bool {
        return false
    }
}
