//
//  AccountViewController.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-16.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

private let notificationViewHeight: CGFloat = 48.0

class AccountViewController: UIViewController, Trackable, Subscriber {

    private let store: Store
    private let headerView = AccountHeaderView()
    private let footerView = AccountFooterView()
    private let notificationView = SyncProgressView()
    private let transactions = TransactionsTableViewController()
    private let headerHeight: CGFloat = 136.0
    private let footerHeight: CGFloat = 56.0
    private var notificationViewTop: NSLayoutConstraint?

    var sendCallback: (() -> Void)? {
        didSet { footerView.sendCallback = sendCallback }
    }
    var receiveCallback: (() -> Void)? {
        didSet { footerView.receiveCallback = receiveCallback }
    }
    var menuCallback: (() -> Void)? {
        didSet { footerView.menuCallback = menuCallback }
    }

    init(store: Store) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        addTransactionsView()

        view.addSubview(headerView)
        view.addSubview(footerView)

        headerView.constrainTopCorners(sidePadding: 0, topPadding: 0)
        headerView.constrain([
            headerView.constraint(.height, constant: headerHeight) ])

        footerView.constrainBottomCorners(sidePadding: 0, bottomPadding: 0)
        footerView.constrain([
            footerView.constraint(.height, constant: footerHeight) ])

        store.subscribe(self, selector: {$0.walletState != $1.walletState },
                        callback: { state in
                            self.notificationView.progress = state.walletState.syncProgress
        })

        store.subscribe(self, selector: {$0.walletState.isSyncing != $1.walletState.isSyncing },
                        callback: { state in
                            if state.walletState.isSyncing {
                                self.showSyncingView()
                            } else {
                                self.hideSyncingView()
                            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        saveEvent("accout:did_appear")
    }

    private func showSyncingView() {
        view.addSubview(notificationView)
        view.bringSubview(toFront: headerView)
        notificationViewTop = notificationView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -notificationViewHeight)
        notificationView.constrain([
            notificationViewTop,
            notificationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notificationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            notificationView.heightAnchor.constraint(equalToConstant: notificationViewHeight) ])

        view.layoutIfNeeded()

        UIView.animate(withDuration: C.animationDuration, animations: { 
            self.transactions.tableView.verticallyOffsetContent(notificationViewHeight)
            self.notificationViewTop?.constant = 0.0
            self.view.layoutIfNeeded()
        }) { completed in
            //This view needs to be brought to the front so that it's above the headerview shadow. It looks weird if it's below.
            self.view.bringSubview(toFront: self.notificationView)
        }
    }

    private func hideSyncingView() {
        if notificationView.superview != nil {
            UIView.animate(withDuration: C.animationDuration, animations: {
                self.transactions.tableView.verticallyOffsetContent(-notificationViewHeight)
                self.notificationViewTop?.constant = -notificationViewHeight
                self.view.layoutIfNeeded()
            }) { completed in
                self.notificationView.removeFromSuperview()
            }
        }
    }

    private func addTransactionsView() {
        addChildViewController(transactions, layout: {
            transactions.view.constrain(toSuperviewEdges: nil)
            transactions.tableView.contentInset = UIEdgeInsets(top: headerHeight + C.padding[2], left: 0, bottom: footerHeight + C.padding[2], right: 0)
            transactions.tableView.scrollIndicatorInsets = UIEdgeInsets(top: headerHeight, left: 0, bottom: footerHeight, right: 0)
        })
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
