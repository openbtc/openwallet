//
//  PaymentRequestTests.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-03-26.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import XCTest
@testable import openwallet

class PaymentRequestTests : XCTestCase {

    func testBasicExample() {
        let uri = "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu"
        let request = PaymentRequest(string: uri)
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.toAddress == "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
    }

    func testAmountInUri() {
        let uri = "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=1.2"
        let request = PaymentRequest(string: uri)
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.toAddress == "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertTrue(request?.amount == 120000000)
    }
}
