//
//  UserDefaults+Additions.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-04-04.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import Foundation

private let defaults = UserDefaults.standard
private let isTouchIdEnabledKey = "istouchidenabled"
private let defaultCurrencyCodeKey = "defaultcurrency"
private let hasAquiredShareDataPermissionKey = "has_acquired_permission"
private let legacyWalletNeedsBackupKey = "WALLET_NEEDS_BACKUP"
private let writePaperPhraseDateKey = "writepaperphrasedatekey"
private let hasPromptedTouchIdKey = "haspromptedtouched"
private let isBtcSwappedKey = "isBtcSwappedKey"
private let maxDigitsKey = "SETTINGS_MAX_DIGITS"

extension UserDefaults {

    static var isTouchIdEnabled: Bool {
        get {
            guard defaults.object(forKey: isTouchIdEnabledKey) != nil else {
                return false
            }
            return defaults.bool(forKey: isTouchIdEnabledKey)
        }
        set {
            defaults.set(newValue, forKey: isTouchIdEnabledKey)
        }
    }

    static var defaultCurrencyCode: String {
        get {
            guard defaults.object(forKey: defaultCurrencyCodeKey) != nil else {
                return Locale.current.currencyCode ?? "USD"
            }
            return defaults.string(forKey: defaultCurrencyCodeKey)!
        }
        set {
            defaults.set(newValue, forKey: defaultCurrencyCodeKey)
        }
    }

    static var hasAquiredShareDataPermission: Bool {
        get {
            guard defaults.object(forKey: hasAquiredShareDataPermissionKey) != nil else {
                return false
            }
            return defaults.bool(forKey: hasAquiredShareDataPermissionKey)
        }
        set {
            defaults.set(newValue, forKey: hasAquiredShareDataPermissionKey)
        }
    }

    static var isBtcSwapped: Bool {
        get {
            return defaults.bool(forKey: isBtcSwappedKey)
        }
        set {
            defaults.set(newValue, forKey: isBtcSwappedKey)
        }
    }

    static var maxDigits: Int {
        get {
            guard defaults.object(forKey: maxDigitsKey) != nil else {
                return 2
            }
            return defaults.integer(forKey: maxDigitsKey)
        }
        set {
            defaults.set(maxDigits, forKey: maxDigitsKey)
        }
    }
}

//MARK: - Wallet Requires Backup
extension UserDefaults {
    static var legacyWalletNeedsBackup: Bool? {
        guard defaults.object(forKey: legacyWalletNeedsBackupKey) != nil else {
            return nil
        }
        return defaults.bool(forKey: legacyWalletNeedsBackupKey)
    }

    static func removeLegacyWalletNeedsBackupKey() {
        defaults.removeObject(forKey: legacyWalletNeedsBackupKey)
    }

    static var writePaperPhraseDate: Date? {
        get {
            return defaults.object(forKey: writePaperPhraseDateKey) as! Date?
        }
        set {
            defaults.set(newValue, forKey: writePaperPhraseDateKey)
        }
    }

    static var walletRequiresBackup: Bool {
        if let legacyWalletNeedsBackup = UserDefaults.legacyWalletNeedsBackup, legacyWalletNeedsBackup == true {
            return true
        }
        if UserDefaults.writePaperPhraseDate == nil {
            return true
        }
        return false
    }
}

//MARK: - Prompts
extension UserDefaults {
    static var hasPromptedTouchId: Bool {
        get {
            return defaults.bool(forKey: hasPromptedTouchIdKey)
        }
        set {
            defaults.set(newValue, forKey: hasPromptedTouchIdKey)
        }
    }
}
