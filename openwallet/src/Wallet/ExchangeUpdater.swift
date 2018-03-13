//
//  ExchangeUpdater.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-01-27.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import Foundation

class ExchangeUpdater {

    //MARK: - Public
    init(store: Store, apiClient: BRAPIClient) {
        self.store = store
        self.apiClient = apiClient
    }

    func refresh(completion: @escaping () -> Void) {
        apiClient.exchangeRates { rates, error in
            guard let currencyCode = Locale.current.currencyCode else { completion(); return }
            guard let currentRate = rates.first( where: { $0.code == currencyCode }) else { completion(); return }
            self.store.perform(action: ExchangeRates.setRates(currentRate: currentRate, rates: rates))
            completion()
        }
    }

    //MARK: - Private
    let store: Store
    let apiClient: BRAPIClient
}
