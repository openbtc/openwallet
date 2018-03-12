//
//  DispatchQueue+Additions.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-04-20.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static var walletQueue: DispatchQueue = {
        return DispatchQueue(label: C.walletQueue)
    }()
}
