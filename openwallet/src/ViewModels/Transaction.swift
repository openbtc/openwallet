//
//  Transaction.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-17.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit
import BRCore

//Ideally this would be a struct, but it needs to be a class to allow
//for lazy variables
class Transaction {

    //MARK: - Public
    init(_ tx: BRTxRef, wallet: BRWallet, blockHeight: UInt32) {
        self.tx = tx
        self.wallet = wallet

        self.fee = wallet.feeForTx(tx) ?? 0
        let amountReceived = wallet.amountReceivedFromTx(tx)
        let amountSent = wallet.amountSentByTx(tx)
        if amountSent > 0 {
            self.direction = .sent
            self.satoshis = amountSent - amountReceived - fee
        } else {
            self.direction = .received
            self.satoshis = amountReceived - fee
        }
        self.timestamp = Int(tx.pointee.timestamp)

        let transactionBlockHeight = tx.pointee.blockHeight
        let transactionIsValid = wallet.transactionIsValid(tx)
        let transactionIsVerified = wallet.transactionIsVerified(tx)
        let transactionIsPending = wallet.transactionIsPending(tx)

        let confirms = transactionBlockHeight > blockHeight ? 0 : Int((blockHeight - transactionBlockHeight) + 1)
        self.status = makeStatus(isValid: transactionIsValid, isPending: transactionIsPending, isVerified: transactionIsVerified, confirms: confirms)
        self.longStatus = confirms > 6 ? "Complete" : "Waiting to be confirmed. Some merchants require confirmation to complete a transaction. Estimated time: 1-2 hours."
        self.hash = tx.pointee.txHash
    }

    func amountDescription(currency: Currency, rate: Rate) -> String {
        let amount = Amount(amount: satoshis, rate: rate.rate)
        return currency == .bitcoin ? amount.bits : amount.localCurrency
    }

    func descriptionString(currency: Currency, rate: Rate) -> NSAttributedString {
        let amount = Amount(amount: satoshis, rate: rate.rate)
        let prefix = NSMutableAttributedString(string: "\(direction.rawValue) ", attributes: UIFont.regularAttributes)
        let amountAttributedString = NSMutableAttributedString(string: amount.string(forCurrency: currency), attributes: UIFont.boldAttributes)
        let preposition = NSMutableAttributedString(string: " \(direction.preposition) ", attributes: UIFont.regularAttributes)
        let suffix = NSMutableAttributedString(string: "account", attributes: UIFont.boldAttributes)
        prefix.append(amountAttributedString)
        prefix.append(preposition)
        prefix.append(suffix)
        return prefix
    }

    func amountDetails(currency: Currency, rate: Rate) -> String {
        let amountString = "\(direction.sign)\(Amount(amount: satoshis, rate: rate.rate).string(forCurrency: currency))"
        let startingString = "Starting balance: \(Amount(amount: startingBalance, rate: rate.rate).string(forCurrency: currency))"
        let endingString = "Ending balance: \(Amount(amount: balanceAfter, rate: rate.rate).string(forCurrency: currency))"
        return "\(amountString)\n\n\(startingString)\n\(endingString)"
    }

    let direction: TransactionDirection
    let status: String
    let longStatus: String
    let timestamp: Int
    let fee: UInt64
    let hash: UInt256

    //MARK: - Private
    private let tx: BRTxRef
    private let wallet: BRWallet
    fileprivate let satoshis: UInt64

    private lazy var balanceAfter: UInt64 = {
        return self.wallet.balanceAfterTx(self.tx)
    }()

    private lazy var startingBalance: UInt64 = {
        switch self.direction {
        case .received:
            return self.balanceAfter - self.satoshis - self.fee
        case .sent:
            return self.balanceAfter + self.satoshis + self.fee
        }
    }()

    var timeSince: String {
        guard timestamp > 0 else { return "just now" }
        let difference = Int(Date().timeIntervalSince1970) - timestamp
        let secondsInMinute = 60
        let secondsInHour = 3600
        let secondsInDay = 86400
        if (difference < secondsInMinute) {
            return "\(difference) s"
        } else if difference < secondsInHour {
            return "\(difference/secondsInMinute) m"
        } else if difference < secondsInDay {
            return "\(difference/secondsInHour) h"
        } else {
            return "\(difference/secondsInDay) d"
        }
    }

    var longTimestamp: String {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        return longDateFormatter.string(from: date)
    }

    private let longDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMMM d, yyy 'at' h:mm a"
        return df
    }()
}

private func makeStatus(isValid: Bool, isPending: Bool, isVerified: Bool, confirms: Int) -> String {
    if confirms == 0 && !isValid {
        return "INVALID"
    } else if confirms == 0 && isPending {
        return "Pending"
    } else if confirms == 0 && !isVerified {
        return "Unverified"
    } else if confirms < 6 {
        if confirms == 0 {
            return "0 confirmations"
        } else if confirms == 1 {
            return "1 confirmation"
        } else {
            return "\(confirms) confirmations"
        }
    } else {
        return "Complete"
    }
}

extension Transaction : Equatable {}

func ==(lhs: Transaction, rhs: Transaction) -> Bool {
    return lhs.hash == rhs.hash && lhs.status == rhs.status
}
