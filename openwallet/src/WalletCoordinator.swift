//
//  WalletCoordinator.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-01-07.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import Foundation
import UIKit //TODO - this shouldn't need uikit

private let lastBlockHeightKey = "LastBlockHeightKey"
private let progressUpdateInterval: TimeInterval = 0.5

class WalletCoordinator : Subscriber {

    var kvStore: BRReplicatedKVStore?

    private let walletManager: WalletManager
    private let store: Store
    private var progressTimer: Timer?
    private let defaults = UserDefaults.standard

    init(walletManager: WalletManager, store: Store) {
        self.walletManager = walletManager
        self.store = store
        addWalletObservers()
        addSubscriptions()
    }

    private var lastBlockHeight: UInt32 {
        set {
            defaults.set(newValue, forKey: lastBlockHeightKey)
        }
        get {
            return UInt32(defaults.integer(forKey: lastBlockHeightKey))
        }
    }

    @objc private func updateProgress() {
        if let progress = walletManager.peerManager?.syncProgress(fromStartHeight: lastBlockHeight) {
            DispatchQueue(label: C.walletQueue).async {
                let timestamp = self.walletManager.lastBlockTimestamp
                DispatchQueue.main.async {
                    self.store.perform(action: WalletChange.setProgress(progress: progress, timestamp: timestamp))
                }
            }
        }
        guard let balance = walletManager.wallet?.balance else { return }
        store.perform(action: WalletChange.setBalance(balance))
    }

    private func onSyncStart() {
        progressTimer = Timer.scheduledTimer(timeInterval: progressUpdateInterval, target: self, selector: #selector(WalletCoordinator.updateProgress), userInfo: nil, repeats: true)
        store.perform(action: WalletChange.setIsSyncing(true))
    }

    private func onSyncSucceed() {
        if let height = walletManager.peerManager?.lastBlockHeight {
            self.lastBlockHeight = height
        }
        progressTimer?.invalidate()
        progressTimer = nil
        store.perform(action: WalletChange.setIsSyncing(false))
    }

    private func onSyncFail(notification: Notification) {
        guard let code = notification.userInfo?["errorCode"] else { return }
        guard let message = notification.userInfo?["errorDescription"] else { return }
        store.perform(action: WalletChange.setSyncingErrorMessage("\(message) (\(code))"))
    }

    private func updateTransactions() {
        guard let blockHeight = self.walletManager.peerManager?.lastBlockHeight else { return }
        guard let transactions = self.walletManager.wallet?.makeTransactionViewModels(blockHeight: blockHeight, kvStore: kvStore) else { return }
        if transactions.count > 0 {
            self.store.perform(action: WalletChange.setTransactions(transactions))
        }
    }

    private func addWalletObservers() {
        NotificationCenter.default.addObserver(forName: .WalletBalanceChangedNotification, object: nil, queue: nil, using: { note in
            guard let balance = self.walletManager.wallet?.balance else { return }
            self.store.perform(action: WalletChange.setBalance(balance))
            self.updateTransactions()
        })

        NotificationCenter.default.addObserver(forName: .WalletTxStatusUpdateNotification, object: nil, queue: nil, using: {note in
            self.updateTransactions()
        })

        NotificationCenter.default.addObserver(forName: .WalletTxRejectedNotification, object: nil, queue: nil, using: {note in
            print("WalletTxRejectedNotification")
        })

        NotificationCenter.default.addObserver(forName: .WalletSyncStartedNotification, object: nil, queue: nil, using: {note in
            self.onSyncStart()
        })

        NotificationCenter.default.addObserver(forName: .WalletSyncSucceededNotification, object: nil, queue: nil, using: {note in
            self.onSyncSucceed()
        })

        NotificationCenter.default.addObserver(forName: .WalletSyncFailedNotification, object: nil, queue: nil, using: {note in
            self.onSyncFail(notification: note)
        })
    }

    private func addSubscriptions() {
        store.subscribe(self, name: .retrySync, callback: {
            DispatchQueue(label: C.walletQueue).async {
                self.walletManager.peerManager?.connect()
            }
        })

        store.subscribe(self, name: .rescan, callback: {
            //In case rescan is called while a sync is in progess
            //we need to make sure it's false before a rescan starts
            //self.store.perform(action: WalletChange.setIsSyncing(false))
            DispatchQueue(label: C.walletQueue).async {
                self.walletManager.peerManager?.rescan()
            }
        })
    }
}
