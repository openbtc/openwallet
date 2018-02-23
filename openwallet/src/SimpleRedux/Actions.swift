//
//  Actions.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-10-22.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

//MARK: - Startup Modals
struct ShowStartFlow : Action {
    let reduce: Reducer = {
        return $0.clone(isStartFlowVisible: true)
    }
}

struct HideStartFlow : Action {
    let reduce: Reducer = { state in
        return State(isStartFlowVisible: false,
                     isLoginRequired: state.isLoginRequired,
                     pinCreationStep: .none,
                     paperPhraseStep: .none,
                     rootModal: .none,
                     pasteboard: UIPasteboard.general.string,
                     walletState: state.walletState,
                     currency: state.currency,
                     currentRate: state.currentRate,
                     alert: state.alert)
    }
}

struct RequireLogin : Action {
    let reduce: Reducer = {
        return $0.clone(isLoginRequired: true)
    }
}

struct LoginSuccess : Action {
    let reduce: Reducer = {
        return $0.clone(isLoginRequired: false)
    }
}

//MARK: - Pin Creation
struct PinCreation {

    struct PinEntryComplete : Action {
        let reduce: Reducer

        init(newPin: String) {
            reduce = {
                switch $0.pinCreationStep {
                case .start:
                    return $0.clone(pinCreationStep: .confirm(pin: newPin))
                case .confirm(let previousPin):
                    return stateForNewPin(newPin: newPin, previousPin: previousPin, state: $0)
                case .confirmFail(let previousPin):
                    return stateForNewPin(newPin: newPin, previousPin: previousPin, state: $0)
                default:
                    assert(false, "Warning - invalid state")
                    return $0
                }
            }
        }
    }

    struct Reset : Action {
        let reduce: Reducer = {
            return $0.clone(pinCreationStep: .none)
        }
    }

    struct Start : Action {
        let reduce: Reducer = {
            return $0.clone(pinCreationStep: .start)
        }
    }

    struct SaveSuccess : Action {
        let reduce: Reducer = {
            switch $0.pinCreationStep {
            case .save(let pin):
                return $0.clone(pinCreationStep: .saveSuccess(pin: pin))
            default:
                assert(false, "Warning - invalid state")
                return $0
            }
        }
    }
}

fileprivate func stateForNewPin(newPin: String, previousPin: String, state: State) -> State {
    if newPin == previousPin {
        return state.clone(pinCreationStep: .save(pin: newPin))
    } else {
        return state.clone(pinCreationStep: .confirmFail(pin: previousPin))
    }
}

//MARK: - Paper Phrase
struct PaperPhrase {
    struct Start: Action {
        let reduce: Reducer = {
            return $0.clone(paperPhraseStep: .start)
        }
    }

    struct Write: Action {
        let reduce: Reducer = {
            return $0.clone(paperPhraseStep: .write)
        }
    }

    struct Confirm: Action {
        let reduce: Reducer = {
            return $0.clone(paperPhraseStep: .confirm)
        }
    }

    struct Confirmed: Action {
        let reduce: Reducer = {
            return $0.clone(paperPhraseStep: .confirmed)
        }
    }
} 

//MARK: - Root Modals
struct RootModalActions {
    struct Present: Action {
        let reduce: Reducer
        init(modal: RootModal) {
            reduce = { $0.rootModal(modal) }
        }
    }
}

//MARK: - Pasteboard
struct Pasteboard {
    struct refresh: Action {
        let reduce: Reducer = { $0.clone(pasteboard: UIPasteboard.general.string) }
    }
}

//MARK: - Wallet State
enum WalletChange {
    struct setProgress: Action {
        let reduce: Reducer
        init(progress: Double, timestamp: UInt32) {
            reduce = { $0.clone(walletSyncProgress: progress, timestamp: timestamp) }
        }
    }
    struct setIsSyncing: Action {
        let reduce: Reducer
        init(_ isSyncing: Bool) {
            reduce = { $0.clone(walletIsSyncing: isSyncing) }
        }
    }
    struct setBalance: Action {
        let reduce: Reducer
        init(_ balance: UInt64) {
            reduce = { $0.clone(balance: balance) }
        }
    }
    struct setTransactions: Action {
        let reduce: Reducer
        init(_ transactions: [Transaction]) {
            reduce = { $0.clone(transactions: transactions) }
        }
    }
    struct setWalletName: Action {
        let reduce: Reducer
        init(_ name: String) {
            reduce = { $0.clone(walletName: name) }
        }
    }
}

//MARK: - Currency
enum CurrencyChange {
    struct toggle: Action {
        let reduce: Reducer = {
            if $0.currency == .bitcoin {
                return $0.clone(currency: .local)
            } else {
                return $0.clone(currency: .bitcoin)
            }
        }
    }
}

//MARK: - Exchange Rates
enum ExchangeRates {
    struct setRate : Action {
        let reduce: Reducer
        init(_ rate: Rate) {
            reduce = { $0.clone(currentRate: rate) }
        }
    }
}

//MARK: - Alerts
enum Alert {
    struct Show : Action {
        let reduce: Reducer
        init(_ type: AlertType) {
            reduce = { $0.clone(alert: type) }
        }
    }
    struct Hide : Action {
        let reduce: Reducer = { $0.clone(alert: nil) }
    }
}

//MARK: - State Creation Helpers
extension State {
    func clone(isStartFlowVisible: Bool) -> State {
        return State(isStartFlowVisible: isStartFlowVisible,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: pinCreationStep,
                     paperPhraseStep: paperPhraseStep,
                     rootModal: rootModal,
                     pasteboard: pasteboard,
                     walletState: walletState,
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }
    func clone(pinCreationStep: PinCreationStep) -> State {
        return State(isStartFlowVisible: isStartFlowVisible,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: pinCreationStep,
                     paperPhraseStep: paperPhraseStep,
                     rootModal: rootModal,
                     pasteboard: pasteboard,
                     walletState: walletState,
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }

    func rootModal(_ type: RootModal) -> State {
        return State(isStartFlowVisible: false,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: .none,
                     paperPhraseStep: .none,
                     rootModal: type,
                     pasteboard: pasteboard,
                     walletState: walletState,
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }
    func clone(pasteboard: String?) -> State {
        return State(isStartFlowVisible: isStartFlowVisible,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: pinCreationStep,
                     paperPhraseStep: paperPhraseStep,
                     rootModal: rootModal,
                     pasteboard: pasteboard,
                     walletState: walletState,
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }
    func clone(isModalDismissalBlocked: Bool) -> State {
        return State(isStartFlowVisible: isStartFlowVisible,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: pinCreationStep,
                     paperPhraseStep: paperPhraseStep,
                     rootModal: rootModal,
                     pasteboard: pasteboard,
                     walletState: walletState,
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }
    func clone(paperPhraseStep: PaperPhraseStep) -> State {
        return State(isStartFlowVisible: isStartFlowVisible,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: pinCreationStep,
                     paperPhraseStep: paperPhraseStep,
                     rootModal: rootModal,
                     pasteboard: pasteboard,
                     walletState: walletState,
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }
    func clone(walletSyncProgress: Double, timestamp: UInt32) -> State {
        return State(isStartFlowVisible: isStartFlowVisible,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: pinCreationStep,
                     paperPhraseStep: paperPhraseStep,
                     rootModal: rootModal,
                     pasteboard: pasteboard,
                     walletState: WalletState(isConnected: walletState.isConnected, syncProgress: walletSyncProgress, isSyncing: walletState.isSyncing, balance: walletState.balance, transactions: walletState.transactions, lastBlockTimestamp: timestamp, name: walletState.name),
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }
    func clone(walletIsSyncing: Bool) -> State {
        return State(isStartFlowVisible: isStartFlowVisible,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: pinCreationStep,
                     paperPhraseStep: paperPhraseStep,
                     rootModal: rootModal,
                     pasteboard: pasteboard,
                     walletState: WalletState(isConnected: walletState.isConnected, syncProgress: walletState.syncProgress, isSyncing: walletIsSyncing, balance: walletState.balance, transactions: walletState.transactions, lastBlockTimestamp: walletState.lastBlockTimestamp, name: walletState.name),
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }
    func clone(balance: UInt64) -> State {
        return State(isStartFlowVisible: isStartFlowVisible,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: pinCreationStep,
                     paperPhraseStep: paperPhraseStep,
                     rootModal: rootModal,
                     pasteboard: pasteboard,
                     walletState: WalletState(isConnected: walletState.isConnected, syncProgress: walletState.syncProgress, isSyncing: walletState.isSyncing, balance: balance, transactions: walletState.transactions, lastBlockTimestamp: walletState.lastBlockTimestamp, name: walletState.name),
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }
    func clone(transactions: [Transaction]) -> State {
        return State(isStartFlowVisible: isStartFlowVisible,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: pinCreationStep,
                     paperPhraseStep: paperPhraseStep,
                     rootModal: rootModal,
                     pasteboard: pasteboard,
                     walletState: WalletState(isConnected: walletState.isConnected, syncProgress: walletState.syncProgress, isSyncing: walletState.isSyncing, balance: walletState.balance, transactions: transactions, lastBlockTimestamp: walletState.lastBlockTimestamp, name: walletState.name),
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }
    func clone(walletName: String) -> State {
        return State(isStartFlowVisible: isStartFlowVisible,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: pinCreationStep,
                     paperPhraseStep: paperPhraseStep,
                     rootModal: rootModal,
                     pasteboard: pasteboard,
                     walletState: WalletState(isConnected: walletState.isConnected, syncProgress: walletState.syncProgress, isSyncing: walletState.isSyncing, balance: walletState.balance, transactions: walletState.transactions, lastBlockTimestamp: walletState.lastBlockTimestamp, name: walletName),
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }
    func clone(currency: Currency) -> State {
        return State(isStartFlowVisible: isStartFlowVisible,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: pinCreationStep,
                     paperPhraseStep: paperPhraseStep,
                     rootModal: rootModal,
                     pasteboard: pasteboard,
                     walletState: walletState,
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }
    func clone(isLoginRequired: Bool) -> State {
        return State(isStartFlowVisible: isStartFlowVisible,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: pinCreationStep,
                     paperPhraseStep: paperPhraseStep,
                     rootModal: rootModal,
                     pasteboard: pasteboard,
                     walletState: walletState,
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }
    func clone(currentRate: Rate) -> State {
        return State(isStartFlowVisible: isStartFlowVisible,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: pinCreationStep,
                     paperPhraseStep: paperPhraseStep,
                     rootModal: rootModal,
                     pasteboard: pasteboard,
                     walletState: walletState,
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }
    func clone(alert: AlertType?) -> State {
        return State(isStartFlowVisible: isStartFlowVisible,
                     isLoginRequired: isLoginRequired,
                     pinCreationStep: pinCreationStep,
                     paperPhraseStep: paperPhraseStep,
                     rootModal: rootModal,
                     pasteboard: pasteboard,
                     walletState: walletState,
                     currency: currency,
                     currentRate: currentRate,
                     alert: alert)
    }
}
