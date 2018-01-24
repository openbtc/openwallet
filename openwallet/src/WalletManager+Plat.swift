//
//  WalletManager+Plat.swift
//  openwallet
//
//  Created by Samuel Sutch on 12/5/16.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import Foundation

// Provide extensions that service the platform functionality (api client, etc)
extension WalletManager {
    public var apiClient: BRAPIClient {
        get {
            return BRAPIClient(authenticator: self)
        }
    }
}
