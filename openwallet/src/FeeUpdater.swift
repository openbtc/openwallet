//
//  FeeUpdater.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-03-02.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import Foundation

class FeeUpdater {

    //MARK: - Public
    init(walletManager: WalletManager, apiClient: BRAPIClient) {
        self.walletManager = walletManager
        self.apiClient = apiClient
    }

    func refresh() {
        apiClient.feePerKb { fee, error in
            guard error == nil else { return print("feePerKb error: \(error)") }
            self.walletManager.wallet?.feePerKb = fee
        }
    }

    //MARK: - Private
    let walletManager: WalletManager
    let apiClient: BRAPIClient
}
