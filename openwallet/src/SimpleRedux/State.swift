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
    let pinCreationStep: PinCreationStep
    let paperPhraseStep: PaperPhraseStep
    let rootModal: RootModal
    let pasteboard: String?
    let isModalDismissalBlocked: Bool
    let walletState: WalletState
    let currency: Currency
    let currentRate: Rate?
    let alert: AlertType?
}

extension State {
    static var initial: State {
        return State(   isStartFlowVisible: false,
                        isLoginRequired: false,
                        pinCreationStep: .none,
                        paperPhraseStep: .none,
                        rootModal: .none,
                        pasteboard: UIPasteboard.general.string,
                        isModalDismissalBlocked: false,
                        walletState: WalletState.initial,
                        currency: .bitcoin,
                        currentRate: nil,
                        alert: nil)
    }
}

enum PinCreationStep {
    case none
    case start
    case confirm(pin: String)
    case confirmFail(pin: String)
    case save(pin: String)
    case saveSuccess(pin: String)
}

enum PaperPhraseStep {
    case none
    case start
    case write
    case confirm
    case confirmed
}

enum RootModal {
    case none
    case send
    case receive
    case menu
    case loginAddress
    case loginScan
    case manageWallet
}

struct WalletState {
    let isConnected: Bool
    let syncProgress: Double
    let isSyncing: Bool
    let balance: UInt64
    let transactions: [Transaction]
    let lastBlockTimestamp: UInt32

    static var initial: WalletState {
        return WalletState(isConnected: false, syncProgress: 0.0, isSyncing: false, balance: 0, transactions: [], lastBlockTimestamp: 0)
    }
}

enum Currency {
    case bitcoin
    case local
}

extension PinCreationStep : Equatable {}

func ==(lhs: PinCreationStep, rhs: PinCreationStep) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none):
        return true
    case (.start, .start):
        return true
    case (.confirm(let leftPin), .confirm(let rightPin)):
        return leftPin == rightPin
    case (.save(let leftPin), .save(let rightPin)):
        return leftPin == rightPin
    case (.confirmFail(let leftPin), .confirmFail(let rightPin)):
        return leftPin == rightPin
    case (.saveSuccess(let leftPin), .saveSuccess(let rightPin)):
        return leftPin == rightPin
    default:
        return false
    }
}

extension WalletState : Equatable {}

func ==(lhs: WalletState, rhs: WalletState) -> Bool {
    return lhs.isConnected == rhs.isConnected && lhs.syncProgress == rhs.syncProgress && lhs.isSyncing == rhs.isSyncing && lhs.balance == rhs.balance && lhs.transactions == rhs.transactions
}
