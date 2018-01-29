//
//  SendViewController.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-30.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

typealias PresentScan = ((@escaping ScanCompletion) -> Void)

class SendViewController: UIViewController, Subscriber {

    init(store: Store) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    var presentScan: PresentScan?

    private let store: Store
    fileprivate let cellHeight: CGFloat = 72.0
    fileprivate let verticalButtonPadding: CGFloat = 32.0
    private let buttonSize = CGSize(width: 52.0, height: 32.0)

    private let to = SendCell(label: S.Send.toLabel)
    private let amount = SendCell(label: S.Send.amountLabel)
    private let pinPad = PinPadViewController()
    private let descriptionCell = SendCell(label: S.Send.descriptionLabel)
    private let send = ShadowButton(title: S.Send.sendLabel, type: .primary, image: #imageLiteral(resourceName: "TouchId"))
    private let paste = ShadowButton(title: S.Send.pasteLabel, type: .tertiary)
    private let scan = ShadowButton(title: S.Send.scanLabel, type: .tertiary)
    private let currency = ShadowButton(title: S.Send.currencyLabel, type: .tertiary)

    override func viewDidLoad() {
        view.addSubview(to)
        view.addSubview(amount)
        view.addSubview(pinPad.view)
        view.addSubview(descriptionCell)
        view.addSubview(send)

        to.accessoryView.addSubview(paste)
        to.accessoryView.addSubview(scan)
        amount.addSubview(currency)
        to.constrainTopCorners(height: cellHeight)
        amount.pinToBottom(to: to, height: cellHeight)

        pinPad.view.constrain([
            pinPad.view.constraint(toBottom: amount, constant: 0.0),
            pinPad.view.constraint(.leading, toView: view),
            pinPad.view.constraint(.trailing, toView: view),
            pinPad.view.constraint(.height, constant: 48.0*4) ])

        descriptionCell.pinToBottom(to: pinPad.view, height: cellHeight)
        send.constrain([
            send.constraint(.leading, toView: view, constant: C.padding[2]),
            send.constraint(.trailing, toView: view, constant: -C.padding[2]),
            send.constraint(toBottom: descriptionCell, constant: verticalButtonPadding),
            send.constraint(.height, constant: C.Sizes.buttonHeight) ])
        scan.constrain([
            scan.constraint(.centerY, toView: to.accessoryView),
            scan.constraint(.trailing, toView: to.accessoryView, constant: -C.padding[2]),
            scan.constraint(.height, constant: buttonSize.height),
            scan.constraint(.width, constant: buttonSize.width) ])
        paste.constrain([
            paste.constraint(.centerY, toView: to.accessoryView),
            paste.constraint(toLeading: scan, constant: -C.padding[1]),
            paste.constraint(.height, constant: buttonSize.height),
            paste.constraint(.width, constant: buttonSize.width),
            paste.constraint(.leading, toView: to.accessoryView) ]) //This constraint is needed because it gives the accessory view an intrinsic horizontal size
        currency.constrain([
            currency.constraint(.centerY, toView: amount),
            currency.constraint(.trailing, toView: amount, constant: -C.padding[2]),
            currency.constraint(.height, constant: buttonSize.height),
            currency.constraint(.width, constant: 64.0) ])
        
        addButtonActions()
    }

    private func addButtonActions() {
        paste.addTarget(self, action: #selector(SendViewController.pasteTapped), for: .touchUpInside)
        scan.addTarget(self, action: #selector(SendViewController.scanTapped), for: .touchUpInside)
        pinPad.ouputDidUpdate = { output in
            self.amount.content = output
        }
    }

    @objc private func pasteTapped() {
        store.subscribe(self, selector: {$0.pasteboard != $1.pasteboard}, callback: {
            if let address = $0.pasteboard {
                if address.isValidAddress {
                    self.to.content = address
                } else {
                    self.invalidAddressAlert()
                }
            }
            self.store.unsubscribe(self)
        })
    }

    @objc private func scanTapped() {
        presentScan? { address in
            self.to.content = address
        }
    }

    private func invalidAddressAlert() {
        let alertController = UIAlertController(title: S.Send.invalidAddressTitle, message: S.Send.invalidAddressMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: S.Button.ok, style: .cancel, handler: nil))
        alertController.view.tintColor = C.defaultTintColor
        present(alertController, animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SendViewController: ModalDisplayable {
    var modalTitle: String {
        return NSLocalizedString("Send Money", comment: "Send modal title")
    }

    var modalSize: CGSize {
        return CGSize(width: view.frame.width, height: cellHeight*3 + verticalButtonPadding*2 + C.Sizes.buttonHeight + 48.0*4)
    }

    var isFaqHidden: Bool {
        return false
    }
}
