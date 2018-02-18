//
//  PhraseTests.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-02-26.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import XCTest
@testable import openwallet

class PhraseTests: XCTestCase {

    private let walletManager: WalletManager = try! WalletManager(dbPath: nil)

    func testEmptyPhrase() {
        XCTAssertFalse(walletManager.isPhraseValid(""), "Empty phrase should not be valid")
    }

    func testInvalidPhrase() {
        XCTAssertFalse(walletManager.isPhraseValid("This is totally and absolutely an invalid bip 39 open recovery phrase"), "Invalid phrase should not be valid")
    }

    func testValidPhrase() {
        XCTAssertTrue(walletManager.isPhraseValid("kind butter gasp around unfair tape again suit else example toast orphan"), "Valid phrase should be valid.")
    }
}
