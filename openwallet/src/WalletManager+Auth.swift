//
//  WalletManager+Auth.swift
//  openwallet
//
//  Created by Aaron Voisine on 11/7/16.
//  Copyright (c) 2016 openwallet LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import UIKit
import LocalAuthentication
import BRCore
import sqlite3

private let WalletSecAttrService = "org.voisine.openwallet"
private let SeedEntropyLength = (128/8)

/// WalletAuthenticator is a protocol whose implementors are able to interact with wallet authentication
public protocol WalletAuthenticator {
    var noWallet: Bool { get }
    var apiAuthKey: String? { get }
    var userAccount: Dictionary<AnyHashable, Any>? { get set }
}

extension WalletManager : WalletAuthenticator {
    static private var failedPins = [String]()
    
    convenience init(dbPath: String? = nil) throws {
        if !UIApplication.shared.isProtectedDataAvailable {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(errSecNotAvailable))
        }
        
        if try keychainItem(key: KeychainKey.seed) as Data? != nil { // upgrade from old keychain scheme
            let seedPhrase: String? = try keychainItem(key: KeychainKey.mnemonic)
            var seed = UInt512()
            print("upgrading to authenticated keychain scheme")
            BRBIP39DeriveKey(&seed.u8.0, seedPhrase, nil)
            let mpk = BRBIP32MasterPubKey(&seed, MemoryLayout<UInt512>.size)
            seed = UInt512() // clear seed
            try setKeychainItem(key: KeychainKey.mnemonic, item: seedPhrase, authenticated: true)
            try setKeychainItem(key: KeychainKey.masterPubKey,
                                item: Data(buffer: UnsafeBufferPointer(start: [mpk], count: 1)))
            try setKeychainItem(key: KeychainKey.seed, item: nil as Data?)
        }

        guard var mpk: Data = try keychainItem(key: KeychainKey.masterPubKey), mpk.count >= 69 else {
            try self.init(masterPubKey: BRMasterPubKey(), earliestKeyTime: 0, dbPath: dbPath)
            return
        }
        
        var earliestKeyTime = TimeInterval(BIP39_CREATION_TIME) - NSTimeIntervalSince1970
        if let creationTime: Data = try keychainItem(key: KeychainKey.creationTime),
            creationTime.count == MemoryLayout<TimeInterval>.stride {
            creationTime.withUnsafeBytes({ earliestKeyTime = $0.pointee })
        }
        
        if mpk.count < MemoryLayout<BRMasterPubKey>.stride { mpk.count = MemoryLayout<BRMasterPubKey>.stride }
        try self.init(masterPubKey: mpk.withUnsafeBytes({ $0.pointee }), earliestKeyTime: earliestKeyTime,
                      dbPath: dbPath)
    }
    
    // true if keychain is available and we know that no wallet exists on it
    var noWallet: Bool {
        if didInitWallet { return false }

        do {
            if try keychainItem(key: KeychainKey.masterPubKey) as Data? != nil { return false }
            if try keychainItem(key: KeychainKey.seed) as Data? != nil { return false } // check for old keychain scheme
            return true
        }
        catch { return false }
    }

    static var hasWallet: Bool {
        do {
            if try keychainItem(key: KeychainKey.masterPubKey) as Data? != nil { return true }
            if try keychainItem(key: KeychainKey.seed) as Data? != nil { return true } // check for old keychain scheme
            return false
        }
        catch { return false }
    }

    //Login with pin should be required if the pin hasn't been used within a week
    var pinLoginRequired: Bool {
        let pinUnlockTime = UserDefaults.standard.double(forKey: DefaultsKey.pinUnlockTime)
        let now = Date.timeIntervalSinceReferenceDate
        let secondsInWeek = 60.0*60.0*24.0*7.0
        return now - pinUnlockTime > secondsInWeek
    }
    
    // true if the given transaction can be signed with touch ID authentication
    func canUseTouchID(forTx: BRTxRef) -> Bool {
        guard LAContext.canUseTouchID else { return false }
        
        do {
            let spendLimit: Int64 = try keychainItem(key: KeychainKey.spendLimit) ?? 0
            guard let wallet = wallet else { return false }
            return wallet.amountSentByTx(forTx) + wallet.totalSent <= UInt64(spendLimit)
        }
        catch { return false }
    }

    var spendingLimit: UInt64 {
        get {
            guard UserDefaults.standard.object(forKey: DefaultsKey.spendLimitAmount) != nil else {
                return 0
            }
            return UInt64(UserDefaults.standard.double(forKey: DefaultsKey.spendLimitAmount))
        }
        set {
            guard let wallet = self.wallet else { assert(false, "No wallet!"); return }
            do {
                try setKeychainItem(key: KeychainKey.spendLimit, item: Int64(wallet.totalSent + spendingLimit))
                UserDefaults.standard.set(newValue, forKey: DefaultsKey.spendLimitAmount)
            } catch let error {
                print("Set spending limit error: \(error)")
            }
        }
    }

    // number of unique failed pin attempts remaining before wallet is wiped
    var pinAttemptsRemaining: Int {
        do {
            let failCount: Int64 = try keychainItem(key: KeychainKey.pinFailCount) ?? 0
            return Int(8 - failCount)
        }
        catch { return -1 }
    }
    
    // after 3 or more failed pin attempts, authentication is disabled until this time (interval since reference date)
    var walletDisabledUntil: TimeInterval {
        do {
            let failCount: Int64 = try keychainItem(key: KeychainKey.pinFailCount) ?? 0
            guard failCount >= 3 else { return 0 }
            let failTime: Int64 = try keychainItem(key: KeychainKey.pinFailTime) ?? 0
            return Double(failTime) + pow(6, Double(failCount - 3))*60
        }
        catch let error {
            assert(false, "Error: \(error)")
            return 0
        }
    }

    var pinLength: Int {
        do {
            if let pin: String = try keychainItem(key: KeychainKey.pin) {
                return pin.utf8.count
            } else {
                return 6
            }
        } catch let error {
            print("Pin keychain error: \(error)")
            return 6
        }
    }

    // true if pin is correct
    func authenticate(pin: String) -> Bool {
        do {
            let secureTime = Date.timeIntervalSinceReferenceDate // TODO: XXX use secure time from https request
            var failCount: Int64 = try keychainItem(key: KeychainKey.pinFailCount) ?? 0

            if failCount >= 3 {
                let failTime: Int64 = try keychainItem(key: KeychainKey.pinFailTime) ?? 0

                if secureTime < Double(failTime) + pow(6, Double(failCount - 3))*60 { // locked out
                    return false
                }
            }
            
            if !WalletManager.failedPins.contains(pin) { // count unique attempts before checking success
                failCount += 1
                try setKeychainItem(key: KeychainKey.pinFailCount, item: failCount)
            }
            
            if try pin == keychainItem(key: KeychainKey.pin) { // successful pin attempt
                try authenticationSuccess()
                return true
            }
            else if !WalletManager.failedPins.contains(pin) { // unique failed attempt
                WalletManager.failedPins.append(pin)
                
                if (failCount >= 8) { // wipe wallet after 8 failed pin attempts and 24+ hours of lockout
                    if !wipeWallet() { return false }
                    return false
                }
                let pinFailTime: Int64 = try keychainItem(key: KeychainKey.pinFailTime) ?? 0
                if secureTime > Double(pinFailTime) {
                    try setKeychainItem(key: KeychainKey.pinFailTime, item: Int64(secureTime))
                }
            }
            
            return false
        }
        catch let error {
            assert(false, "Error: \(error)")
            return false
        }
    }

    private func authenticationSuccess() throws {
        let limit = Int64(UserDefaults.standard.double(forKey: DefaultsKey.spendLimitAmount))

        WalletManager.failedPins.removeAll()
        UserDefaults.standard.set(Date.timeIntervalSinceReferenceDate, forKey: DefaultsKey.pinUnlockTime)
        try setKeychainItem(key: KeychainKey.pinFailTime, item: Int64(0))
        try setKeychainItem(key: KeychainKey.pinFailCount, item: Int64(0))

        if let wallet = wallet, limit > 0 {
            try setKeychainItem(key: KeychainKey.spendLimit,
                                item: Int64(wallet.totalSent) + limit)
        }
    }

    // show touch ID dialog and call completion block with success or failure
    func authenticate(touchIDPrompt: String, completion: @escaping (Bool) -> ()) {
        LAContext().evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: touchIDPrompt,
                                   reply: { success, _ in DispatchQueue.main.async { completion(success) } })
    }
    
    // sign the given transaction using pin authentication
    func signTransaction(_ tx: BRTxRef, pin: String) -> Bool {
        guard authenticate(pin: pin) else { return false }
        return signTx(tx)
    }
    
    // sign the given transaction using touch ID authentication
    func signTransaction(_ tx: BRTxRef, touchIDPrompt: String, completion: @escaping (Bool) -> ()) {
        do {
            let spendLimit: Int64 = try keychainItem(key: KeychainKey.spendLimit) ?? 0
            guard let wallet = wallet, wallet.amountSentByTx(tx) + wallet.totalSent <= UInt64(spendLimit) else {
                return completion(false)
            }
        }
        catch { return completion(false) }
            
        authenticate(touchIDPrompt: touchIDPrompt) { success in
            guard success else { return completion(false) }
            
            completion(self.signTx(tx))
        }
    }
    
    // the 12 word wallet recovery phrase
    func seedPhrase(pin: String) -> String? {
        guard authenticate(pin: pin) else { return nil }
        
        do {
            return try keychainItem(key: KeychainKey.mnemonic)
        }
        catch { return nil }
    }

    // recover an existing wallet using 12 word wallet recovery phrase
    // will fail if a wallet already exists on the keychain
    func setSeedPhrase(_ phrase: String) -> Bool {
        guard noWallet else { return false }
        
        do {
            var seed = UInt512()
            try setKeychainItem(key: KeychainKey.mnemonic, item: phrase, authenticated: true)
            BRBIP39DeriveKey(&seed.u8.0, phrase, nil)
            masterPubKey = BRBIP32MasterPubKey(&seed, MemoryLayout<UInt512>.size)
            seed = UInt512() // clear seed
            try setKeychainItem(key: KeychainKey.masterPubKey,
                                item: Data(buffer: UnsafeBufferPointer(start: [masterPubKey], count: 1)))
            return true
        }
        catch { return false }
    }
    
    // create a new wallet and return the 12 word wallet recovery phrase
    // will fail if a wallet already exists on the keychain
    func setRandomSeedPhrase() -> String? {
        guard noWallet else { return nil }
        guard var words = rawWordList else { return nil }
        let time = Date.timeIntervalSinceReferenceDate

        // we store the wallet creation time on the keychain because keychain data persists even when app is deleted
        do {
            try setKeychainItem(key: KeychainKey.creationTime,
                                item: Data(buffer: UnsafeBufferPointer(start: [time], count: 1)))
            self.earliestKeyTime = time
        }
        catch { return nil }

        // wrapping in an autorelease pool ensures sensitive memory is wiped and released immediately
        return autoreleasepool {
            var entropy = CFDataCreateMutable(secureAllocator, SeedEntropyLength) as Data
            entropy.count = SeedEntropyLength
            guard entropy.withUnsafeMutableBytes({ SecRandomCopyBytes(kSecRandomDefault, entropy.count, $0) }) == 0
                else { return nil }
            let phraseLen = entropy.withUnsafeBytes({ BRBIP39Encode(nil, 0, &words, $0, entropy.count) })
            var phraseData = CFDataCreateMutable(secureAllocator, phraseLen) as Data
            phraseData.count = phraseLen
            guard phraseData.withUnsafeMutableBytes({ bytes -> Int in
                entropy.withUnsafeBytes({ BRBIP39Encode(bytes, phraseData.count, &words, $0, entropy.count) })
            }) == phraseData.count else { return nil }
            let phrase = CFStringCreateFromExternalRepresentation(secureAllocator, phraseData as CFData,
                                                                  CFStringBuiltInEncodings.UTF8.rawValue) as String
            guard setSeedPhrase(phrase) else { return nil }
            return phrase
        }
    }
    
    // change wallet authentication pin
    func changePin(newPin: String, pin: String) -> Bool {
        guard authenticate(pin: pin) else { return false }

        do {
            try setKeychainItem(key: KeychainKey.pin, item: newPin)
            return true
        }
        catch { return false }
    }
    
    // change wallet authentication pin using the wallet recovery phrase
    // recovery phrase is optional if no pin is currently set
    func forceSetPin(newPin: String, seedPhrase: String? = nil) -> Bool {
        do {
            if seedPhrase != nil {
                var seed = UInt512()
                BRBIP39DeriveKey(&seed.u8.0, seedPhrase, nil)
                let mpk = BRBIP32MasterPubKey(&seed, MemoryLayout<UInt512>.size)
                seed = UInt512() // clear seed
                guard var mpkData: Data = try keychainItem(key: KeychainKey.masterPubKey) else { return false }
                mpkData.count = MemoryLayout<BRMasterPubKey>.stride
                guard mpkData.withUnsafeBytes({ $0.pointee == mpk }) else { return false }
            }
            else if try keychainItem(key: KeychainKey.pin) != nil { return false }
            
            try setKeychainItem(key: KeychainKey.pin, item: newPin)
            try authenticationSuccess()
            return true
        }
        catch { return false }
    }
    
    // wipe the existing wallet from the keychain
    func wipeWallet(pin: String = "forceWipe") -> Bool {
        guard pin == "forceWipe" || authenticate(pin: pin) else { return false }

        do {
            peerManager = nil
            if db != nil { sqlite3_close(db) }
            db = nil
            masterPubKey = BRMasterPubKey()
            earliestKeyTime = 0
            try BRAPIClient(authenticator: self).kv?.rmdb()
            try FileManager.default.removeItem(atPath: dbPath)
            try setKeychainItem(key: KeychainKey.apiAuthKey, item: nil as Data?)
            try setKeychainItem(key: KeychainKey.spendLimit, item: nil as Int64?)
            try setKeychainItem(key: KeychainKey.creationTime, item: nil as Data?)
            try setKeychainItem(key: KeychainKey.pinFailTime, item: nil as Int64?)
            try setKeychainItem(key: KeychainKey.pinFailCount, item: nil as Int64?)
            try setKeychainItem(key: KeychainKey.pin, item: nil as String?)
            try setKeychainItem(key: KeychainKey.masterPubKey, item: nil as Data?)
            try setKeychainItem(key: KeychainKey.seed, item: nil as Data?)
            try setKeychainItem(key: KeychainKey.mnemonic, item: nil as String?, authenticated: true)
            return true
        }
        catch { return false }
    }
    
    // key used for authenticated API calls
    var apiAuthKey: String? {
        return autoreleasepool {
            do {
                if let apiKey: String? = try? keychainItem(key: KeychainKey.apiAuthKey) {
                    if apiKey != nil {
                        return apiKey
                    }
                }
                var key = BRKey()
                var seed = UInt512()
                guard let phrase: String = try keychainItem(key: KeychainKey.mnemonic) else { return nil }
                BRBIP39DeriveKey(&seed.u8.0, phrase, nil)
                BRBIP32APIAuthKey(&key, &seed, MemoryLayout<UInt512>.size)
                seed = UInt512() // clear seed
                let pkLen = BRKeyPrivKey(&key, nil, 0)
                var pkData = CFDataCreateMutable(secureAllocator, pkLen) as Data
                pkData.count = pkLen
                guard pkData.withUnsafeMutableBytes({ BRKeyPrivKey(&key, $0, pkLen) }) == pkLen else { return nil }
                let privKey = CFStringCreateFromExternalRepresentation(secureAllocator, pkData as CFData,
                                                                       CFStringBuiltInEncodings.UTF8.rawValue) as String
                try setKeychainItem(key: KeychainKey.apiAuthKey, item: privKey)
                return privKey
            }
            catch let error {
                print("apiAuthKey error: \(error)")
                return nil
            }
        }
    }

    // sensitive user information stored on the keychain
    var userAccount: Dictionary<AnyHashable, Any>? {
        get {
            do {
                return try keychainItem(key: KeychainKey.userAccount)
            }
            catch { return nil }
        }

        set (value) {
            do {
                try setKeychainItem(key: KeychainKey.userAccount, item: value)
            }
            catch { }
        }
    }
    
    private struct KeychainKey {
        public static let mnemonic = "mnemonic"
        public static let creationTime = "creationtime"
        public static let masterPubKey = "masterpubkey"
        public static let spendLimit = "spendlimit"
        public static let pin = "pin"
        public static let pinFailCount = "pinfailcount"
        public static let pinFailTime = "pinfailheight"
        public static let apiAuthKey = "authprivkey"
        public static let userAccount = "https://api.openwallet.com"
        public static let seed = "seed" // deprecated
    }
    
    private struct DefaultsKey {
        public static let spendLimitAmount = "SPEND_LIMIT_AMOUNT"
        public static let pinUnlockTime = "PIN_UNLOCK_TIME"
    }
    
    private func signTx(_ tx: BRTxRef) -> Bool {
        return autoreleasepool {
            do {
                var seed = UInt512()
                defer { seed = UInt512() }
                guard let wallet = wallet else { return false }
                guard let phrase: String = try keychainItem(key: KeychainKey.mnemonic) else { return false }
                BRBIP39DeriveKey(&seed.u8.0, phrase, nil)
                return wallet.signTransaction(tx, seed: &seed)
            }
            catch { return false }
        }
    }
}

private func keychainItem<T>(key: String) throws -> T? {
    let query = [kSecClass as String : kSecClassGenericPassword as String,
                 kSecAttrService as String : WalletSecAttrService,
                 kSecAttrAccount as String : key,
                 kSecReturnData as String : true as Any]
    var result: CFTypeRef? = nil
    let status = SecItemCopyMatching(query as CFDictionary, &result);
    guard status == noErr || status == errSecItemNotFound else {
        throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
    }
    guard let data = result as? Data else { return nil }
    
    switch T.self {
    case is Data.Type:
        return data as? T
    case is String.Type:
        return CFStringCreateFromExternalRepresentation(secureAllocator, data as CFData,
                                                        CFStringBuiltInEncodings.UTF8.rawValue) as? T
    case is Int64.Type:
        guard data.count == MemoryLayout<T>.stride else { return nil }
        return data.withUnsafeBytes({ $0.pointee })
    case is Dictionary<AnyHashable, Any>.Type:
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? T
    default:
        throw NSError(domain: NSOSStatusErrorDomain, code: Int(errSecParam))
    }
}

private func setKeychainItem<T>(key: String, item: T?, authenticated: Bool = false) throws {
    let accessible = (authenticated) ? kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
                                     : kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
    let query = [kSecClass as String : kSecClassGenericPassword as String,
                 kSecAttrService as String : WalletSecAttrService,
                 kSecAttrAccount as String : key]
    var status = noErr
    var data: Data? = nil
    if let item = item {
        switch T.self {
        case is Data.Type:
            data = item as? Data
        case is String.Type:
            data = CFStringCreateExternalRepresentation(secureAllocator, item as! CFString,
                                                        CFStringBuiltInEncodings.UTF8.rawValue, 0) as Data
        case is Int64.Type:
            data = CFDataCreateMutable(secureAllocator, MemoryLayout<T>.stride) as Data
            data?.append(UnsafeBufferPointer(start: [item], count: 1))
        case is Dictionary<AnyHashable, Any>.Type:
            data = NSKeyedArchiver.archivedData(withRootObject: item)
        default:
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(errSecParam))
        }
    }
    
    if data == nil { // delete item
        if SecItemCopyMatching(query as CFDictionary, nil) != errSecItemNotFound {
            status = SecItemDelete(query as CFDictionary)
        }
    }
    else if SecItemCopyMatching(query as CFDictionary, nil) != errSecItemNotFound { // update existing item
        let update = [kSecAttrAccessible as String : accessible,
                      kSecValueData as String : data as Any]
        status = SecItemUpdate(query as CFDictionary, update as CFDictionary)
    }
    else { // add new item
        let item = [kSecClass as String : kSecClassGenericPassword as String,
                    kSecAttrService as String : WalletSecAttrService,
                    kSecAttrAccount as String : key,
                    kSecAttrAccessible as String : accessible,
                    kSecValueData as String : data as Any]
        status = SecItemAdd(item as CFDictionary, nil)
    }
    
    guard status == noErr else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status)) }
}

