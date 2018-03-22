//
//  State.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-10-24.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

struct State {
    let isStartFlowVisible: Bool
    let isLoginRequired: Bool
    let rootModal: RootModal
    let pasteboard: String?
    let walletState: WalletState
    let isBtcSwapped: Bool
    let currentRate: Rate?
    let rates: [Rate]
    let alert: AlertType?
    let isTouchIdEnabled: Bool
    let defaultCurrencyCode: String
    let recommendRescan: Bool
    let isLoadingTransactions: Bool
    let maxDigits: Int
}

extension State {
    static var initial: State {
        return State(   isStartFlowVisible: false,
                        isLoginRequired: true,
                        rootModal: .none,
                        pasteboard: UIPasteboard.general.string,
                        walletState: WalletState.initial,
                        isBtcSwapped: UserDefaults.isBtcSwapped,
                        currentRate: nil,
                        rates: [],
                        alert: nil,
                        isTouchIdEnabled: UserDefaults.isTouchIdEnabled,
                        defaultCurrencyCode: UserDefaults.defaultCurrencyCode,
                        recommendRescan: false,
                        isLoadingTransactions: false,
                        maxDigits: UserDefaults.maxDigits)
    }
}

enum RootModal {
    case none
    case send
    case receive
    case menu
    case loginAddress
    case loginScan
    case manageWallet
    case requestAmount
}

struct WalletState {
    let isConnected: Bool
    let syncProgress: Double
    let isSyncing: Bool
    let balance: UInt64
    let transactions: [Transaction]
    let lastBlockTimestamp: UInt32
    let name: String
    let syncErrorMessage: String?
    let creationDate: Date
    static var initial: WalletState {
        return WalletState(isConnected: false, syncProgress: 0.0, isSyncing: false, balance: 0, transactions: [], lastBlockTimestamp: 0, name: S.AccountHeader.defaultWalletName, syncErrorMessage: nil, creationDate: Date.zeroValue())
    }
}

extension WalletState : Equatable {}

func ==(lhs: WalletState, rhs: WalletState) -> Bool {
    return lhs.isConnected == rhs.isConnected && lhs.syncProgress == rhs.syncProgress && lhs.isSyncing == rhs.isSyncing && lhs.balance == rhs.balance && lhs.transactions == rhs.transactions && lhs.name == rhs.name && lhs.syncErrorMessage == rhs.syncErrorMessage && lhs.creationDate == rhs.creationDate
}
