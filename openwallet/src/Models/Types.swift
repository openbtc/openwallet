//
//  Types.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-05-20.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import Foundation

//MARK: - Satishis
struct Satoshis {
    let rawValue: UInt64
}

extension Satoshis {
    init(bits: Bits) {
        rawValue = UInt64((bits.rawValue * 100.0).rounded(.toNearestOrEven))
    }

    init(value: Double, rate: Rate) {
        rawValue = UInt64((value / rate.rate * Double(C.satoshis)).rounded(.toNearestOrEven))
    }

    init?(btcString: String) {
        var decimal: Decimal = 0.0
        var amount: Decimal = 0.0
        guard Scanner(string: btcString).scanDecimal(&decimal) else { return nil }
        NSDecimalMultiplyByPowerOf10(&amount, &decimal, 8, .up)
        rawValue = NSDecimalNumber(decimal: amount).uint64Value
    }
}

//MARK: - Bits
struct Bits {
    let rawValue: Double
}

extension Bits {

    init(satoshis: Satoshis) {
        rawValue = Double(satoshis.rawValue)/100.0
    }

    init?(string: String) {
        guard let value = Double(string) else { return nil }
        rawValue = value
    }
}

