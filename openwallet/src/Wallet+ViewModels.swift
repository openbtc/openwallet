//
//  Wallet+ViewModels.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-01-12.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import Foundation
import BRCore

extension BRWallet {
    func makeTransactionViewModels(blockHeight: UInt32, kvStore: BRReplicatedKVStore?, rate: Rate?) -> [Transaction] {
        return transactions.flatMap{ $0 }.sorted {
                if $0.pointee.timestamp == 0 {
                    return true
                } else if $1.pointee.timestamp == 0 {
                    return false
                } else {
                    return $0.pointee.timestamp > $1.pointee.timestamp
                }
            }.map {
                return Transaction($0, wallet: self, blockHeight: blockHeight, kvStore: kvStore, rate: rate)
            }
    }
}
