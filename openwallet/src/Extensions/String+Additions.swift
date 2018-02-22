//
//  String+Additions.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-12-12.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

extension String {
    var isValidAddress: Bool {
        guard lengthOfBytes(using: .utf8) > 0 else { return false }
        #if Testnet
            return true
        #endif
        if characters.first == "1" || characters.first == "3" {
            return true
        } else {
            return false
        }
    }
}
