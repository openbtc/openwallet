//
//  Strings.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-12-14.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import Foundation

enum S {

    enum Symbols {
        static let bits = "ƀ"
        static let narrowSpace = "\u{2009}"
    }

    enum Button {
        static let ok = NSLocalizedString("Button.ok", value:"OK", comment: "OK button label")
        static let cancel = NSLocalizedString("Button.cancel", value:"Cancel", comment: "Cancel button label")
        static let settings = NSLocalizedString("Button.settings", value:"Settings", comment: "Settings button label")
        static let submit = NSLocalizedString("Button.submit", value:"Submit", comment: "Settings button label")
    }

    enum Scanner {
        static let flashButtonLabel = NSLocalizedString("Scanner.flashButtonLabel", value:"Camera Flash", comment: "Scan bitcoin address camera flash toggle")
    }

    enum Send {
        static let toLabel = NSLocalizedString("Send.toLabel", value:"To", comment: "Send money to label")
        static let amountLabel = NSLocalizedString("Send.amountLabel", value:"Amount", comment: "Send money amount label")
        static let descriptionLabel = NSLocalizedString("Send.descriptionLabel", value:"What's this for?", comment: "Description for sending money label")
        static let sendLabel = NSLocalizedString("Send.sendLabel", value:"Send", comment: "Send button label")
        static let pasteLabel = NSLocalizedString("Send.pasteLabel", value:"Paste", comment: "Paste button label")
        static let scanLabel = NSLocalizedString("Send.scanLabel", value:"Scan", comment: "Scan button label")
        static let defaultCurrencyLabel = NSLocalizedString("Send.defaultCurrencyLabel", value:"BTC (\(S.Symbols.bits))", comment: "Currency Button label")
        static let invalidAddressTitle = NSLocalizedString("Send.invalidAddressTitle", value:"Invalid Address", comment: "Invalid address alert title")
        static let invalidAddressMessage = NSLocalizedString("Send.invalidAddressTitle", value:"Your clipboard does not have a valid bitcoin address.", comment: "Invalid address alert message")

        static let cameraUnavailableTitle = NSLocalizedString("Send.cameraUnavailableTitle", value:"Bread is not allowed to access the camera", comment: "Camera not allowed alert title")
        static let cameraUnavailableMessage = NSLocalizedString("Send.cameraunavailableMessage", value:"Go to Settings to Allow camera access.", comment: "Camera not allowed message")
        static let modalTitle = NSLocalizedString("Send.modalTitle", value:"Send Money", comment: "Send modal title")
        static let touchIdPrompt = NSLocalizedString("Send.touchIdPrompt", value:"Authenticate transaction.", comment: "Send with TouchID prompt text")
        static let balance = NSLocalizedString("Send.balance", value:"Balance: %@", comment: "Balance: $4.00")
        static let balanceWithFee = NSLocalizedString("Send.balanceWithFee", value:"Balance: %@ Fee: %@", comment: "Balance: $4.00, Fee: $0.01")
    }

    enum Receive {
        static let title = NSLocalizedString("Receive.title", value:"Receive", comment: "Receive modal title")
        static let emailButton = NSLocalizedString("Receive.emailButton", value:"Email", comment: "Share via email button label")
        static let textButton = NSLocalizedString("Receive.textButton", value:"Text Message", comment: "Share via text message label")
        static let copied = NSLocalizedString("Receive.copied", value:"Copied to Clipboard.", comment: "Address copied message.")
        static let share = NSLocalizedString("Receive.share", value:"Share", comment: "Share button label")
        static let request = NSLocalizedString("Receive.request", value:"Request an Amount", comment: "Request button label")
    }

    enum Account {
        static let loadingMessage = NSLocalizedString("Account.loadingMessage", value:"Loading Wallet", comment: "Loading Wallet Message")
    }

    enum JailbreakWarnings {
        static let title = NSLocalizedString("JailbreakWarnings.title", value:"WARNING", comment: "Jailbreak warning title")
        static let messageWithBalance = NSLocalizedString("JailbreakWarnings.messageWithBalance", value:"DEVICE SECURITY COMPROMISED\n Any 'jailbreak' app can access any other app's keychain data (and steal your bitcoins). Wipe this wallet immediately and restore on a secure device.", comment: "Jailbreak warning message")
        static let messageWithoutBalance = NSLocalizedString("JailbreakWarnings.messageWithoutBalance", value:"DEVICE SECURITY COMPROMISED\n Any 'jailbreak' app can access any other app's keychain data (and steal your bitcoins).", comment: "Jailbreak warning message")
        static let ignore = NSLocalizedString("JailbreakWarnings.ignore", value:"Ignore", comment: "Ignore jailbreak warning button")
        static let wipe = NSLocalizedString("JailbreakWarnings.wipe", value:"Wipe", comment: "Wipe wallet button")
        static let close = NSLocalizedString("JailbreakWarnings.close", value:"Close", comment: "Close app button")
    }

    enum ErrorMessages {
        static let emailUnavailableTitle = NSLocalizedString("ErrorMessages.emailUnavailableTitle", value:"Email unavailable", comment: "Email unavailable alert title")
        static let emailUnavailableMessage = NSLocalizedString("ErrorMessages.emailUnavailableMessage", value:"This device isn't configured to send email with the iOS mail app.", comment: "Email unavailable alert title")
        static let messagingUnavailableTitle = NSLocalizedString("ErrorMessages.messagingUnavailableTitle", value:"Messaging unavailable", comment: "Messaging unavailable alert title")
        static let messagingUnavailableMessage = NSLocalizedString("ErrorMessages.messagingUnavailableMessage", value:"This device isn't configured to send messages.", comment: "Messaging unavailable alert title")
    }

    enum LoginScreen {
        static let myAddress = NSLocalizedString("LoginScreen.myAddress", value:"My Address", comment: "My Address button title")
        static let scan = NSLocalizedString("LoginScreen.scan", value:"Scan", comment: "Scan button title")
        static let touchIdText = NSLocalizedString("LoginScreen.touchIdText", value:"Login With TouchID", comment: "Login with TouchID accessibility label")
        static let touchIdPrompt = NSLocalizedString("LoginScreen.touchIdPrompt", value:"Unlock your Breadwallet", comment: "TouchID prompt text")
        static let subheader = NSLocalizedString("LoginScreen.subheader", value:"Enter Pin", comment: "Login Screen sub-header")
        static let unlocked = NSLocalizedString("LoginScreen.unlocked", value:"Wallet Unlocked", comment: "Wallet unlocked message")
        static let disabled = NSLocalizedString("LoginScreen.disabled", value:"Disabled until: %@", comment: "Disabled until date")
        static let resetPin = NSLocalizedString("LoginScreen.resetPin", value:"User Paper Key", comment: "Reset Pin with Paper Key button label.")
    }

    enum Transaction {
        static let justNow = NSLocalizedString("Transaction.justNow", value:"just now", comment: "Timestamp label for event that just happened")
        static let invalid = NSLocalizedString("Transaction.invalid", value:"INVALID", comment: "Invalid transaction")
        static let complete = NSLocalizedString("Transaction.complete", value:"Complete", comment: "Transaction complete label")
        static let waiting = NSLocalizedString("Transaction.waiting", value:"Waiting to be confirmed. Some merchants require confirmation to complete a transaction. Estimated time: 1-2 hours.", comment: "Waiting to be confirmed string")
    }

    enum TransactionDetails {
        static let title = NSLocalizedString("TransactionDetails.title", value:"Transaction Details", comment: "Transaction Details Title")
        static let statusHeader = NSLocalizedString("TransactionDetails.statusHeader", value:"Status", comment: "Status section header")
        static let commentsHeader = NSLocalizedString("TransactionDetails.commentsHeader", value:"Comments", comment: "Comment section header")
        static let amountHeader = NSLocalizedString("TransactionDetails.amountHeader", value:"Amount", comment: "Amount section header")
        static let emptyMessage = NSLocalizedString("TransactionDetails.emptyMessage", value:"Your transactions will appear here.", comment: "Empty transaction list message.")
        static let more = NSLocalizedString("TransactionDetails.more", value:"More...", comment: "More button title")
        static let txHashHeader = NSLocalizedString("TransactionDetails.txHashHeader", value:"Transaction Hash", comment: "Transaction hash header")
        static let addressFormat = NSLocalizedString("TransactionDetails.addressFormat", value:"%@ an address", comment: "Will read 'for and address' or 'to and address'")
    }

    enum SecurityCenter {
        static let title = NSLocalizedString("SecurityCenter.title", value:"Security Center", comment: "Security Center Title")
        static let info = NSLocalizedString("SecurityCenter.info", value:"Breadwallet provides security features for protecting your money. Click each feature below to learn more.", comment: "Security Center Info")
        enum Cells {
            static let pinTitle = NSLocalizedString("SecurityCenter.pinTitle", value:"6-Digit PIN", comment: "Pin cell title")
            static let pinDescription = NSLocalizedString("SecurityCenter.pinDescription", value:"Unlocks your Bread, authorizes send money.", comment: "Pin cell description")
            static let touchIdTitle = NSLocalizedString("SecurityCenter.touchIdTitle", value:"Touch ID", comment: "Touch ID cell title")
            static let touchIdDescription = NSLocalizedString("SecurityCenter.touchIdDescription", value:"Unlocks your Bread, authorizes send money to set limit.", comment: "Touch ID cell description")
            static let paperKeyTitle = NSLocalizedString("SecurityCenter.paperKeyTitle", value:"Paper Key", comment: "Paper Key cell title")
            static let paperKeyDescription = NSLocalizedString("SecurityCenter.paperKeyDescription", value:"Restores your Bread on new devices and after software updates.", comment: "Paper Key cell description")
        }
    }

    enum UpdatePin {
        static let updateTitle = NSLocalizedString("UpdatePin.updateTitle", value:"Update PIN", comment: "Update Pin title")
        static let createTitle = NSLocalizedString("UpdatePin.createTitle", value:"Set PIN", comment: "Update Pin title")
        static let createTitleConfirm = NSLocalizedString("UpdatePin.createTitleConfirm", value:"Re-Enter PIN", comment: "Update Pin title")
        static let createInstruction = NSLocalizedString("UpdatePin.createInstruction", value:"Your PIN will be used to unlock your Bread and send money.", comment: "Pin creation info.")
        static let enterCurrent = NSLocalizedString("UpdatePin.enterCurrent", value:"Enter your current PIN.", comment: "Enter current pin instruction")
        static let enterNew = NSLocalizedString("UpdatePin.enterNew", value:"Enter your new PIN.", comment: "Enter new pin instruction")
        static let reEnterNew = NSLocalizedString("UpdatePin.reEnterNew", value:"Re-Enter your new PIN", comment: "Re-Enter new pin instruction")
        static let caption = NSLocalizedString("UpdatePin.caption", value:"Write down your PIN and store it in a place you can access even if your phone is broken or lost.", comment: "Update pin caption text")
        static let setPinErrorTitle = NSLocalizedString("UpdatePin.setPinErrorTitle", value:"Set Pin Error", comment: "Update pin failure alert view title")
        static let setPinError = NSLocalizedString("UpdatePin.setPinError", value:"Sorry, could not update pin.", comment: "Update pin failure error message.")
    }

    enum RecoverWallet {
        static let next = NSLocalizedString("RecoverWallet.next", value:"Next", comment: "Next button label")
        static let intro = NSLocalizedString("RecoverWallet.intro", value:"Recover your Breadwallet with your paper key.", comment: "Recover wallet intro")
        static let leftArrow = NSLocalizedString("RecoverWallet.leftArrow", value:"Left Arrow", comment: "Previous button accessibility label")
        static let rightArrow = NSLocalizedString("RecoverWallet.rightArrow", value:"Right Arrow", comment: "Next button accessibility label")
        static let done = NSLocalizedString("RecoverWallet.done", value:"Done", comment: "Done buttohn text")
        static let instruction = NSLocalizedString("RecoverWallet.instruction", value:"Enter Paper Key", comment: "Enter paper key instruction")
        static let header = NSLocalizedString("RecoverWallet.header", value:"Recover Wallet", comment: "Recover wallet header")
        static let subheader = NSLocalizedString("RecoverWallet.subheader", value:"Enter the paper key associated with the wallet you want to recover.", comment: "Recover wallet sub-header")

        static let headerResetPin = NSLocalizedString("RecoverWallet.header-reset-pin", value:"Reset Pin", comment: "Reset Pin with paper key header")
        static let subheaderResetPin = NSLocalizedString("RecoverWallet.subheader-reset-pin", value:"To reset your PIN, enter the words from your paper key into the boxes below.", comment: "Reset pin with papker key sub-header")
        static let resetPinInfo = NSLocalizedString("RecoverWallet.reset-pin-more-info", value:"Tap here for more information.", comment: "Reset pin with papker key more information button.")
        static let invalid = NSLocalizedString("RecoverWallet.invalid", value:"The paper key you entered is invalid. Please double-check each word and try again.", comment: "Invalid paper key message")
    }

    enum ManageWallet {
        static let title = NSLocalizedString("ManageWallet.title", value:"Manage Wallet", comment: "Manage wallet modal title[")
        static let textFieldLabel = NSLocalizedString("ManageWallet.textFeildLabel", value:"Wallet Name", comment: "Change Wallet name textfield label")
        static let description = NSLocalizedString("ManageWallet.description", value:"Your wallet name only appears in your account transaction history and cannot be seen by anyone you pay or receive money from.", comment: "Manage wallet description text")
        static let creationDatePrefix = NSLocalizedString("ManageWallet.creationDatePrefix", value:"You created your wallet on", comment: "Wallet creation date prefix")
    }

    enum AccountHeader {
        static let defaultWalletName = NSLocalizedString("AccountHeader.defaultWalletName", value:"My Bread", comment: "Default wallet name")
        static let manageButtonName = NSLocalizedString("AccountHeader.manageButtonName", value:"MANAGE", comment: "Manage wallet button title")
        static let equals = NSLocalizedString("AccountHeader.equals", value:"=", comment: "Equals symbol")
    }

    enum VerifyPin {
        static let title = NSLocalizedString("VerifyPin.title", value:"PIN Required", comment: "Verify Pin view title")
        static let body = NSLocalizedString("VerifyPin.body", value:"Please enter your PIN to authorize this transaction.", comment: "Verify pin view body")
    }

    enum TouchIdSettings {
        static let title = NSLocalizedString("TouchIdSettings.title", value:"Touch ID", comment: "Touch ID settings view title")
        static let label = NSLocalizedString("TouchIdSettings.label", value:"Login to your Bread wallet and send money using just your finger print to a set limit.", comment: "Touch Id screen label")
        static let switchLabel = NSLocalizedString("TouchIdSettings.switchLabel", value:"Enable Touch ID for Bread", comment: "Touch id switch label.")
        static let unavailableAlertTitle = NSLocalizedString("TouchIdSettings.unavailableAlertTitle", value:"Touch ID Not Setup", comment: "Touch ID unavailable alert title")
        static let unavailableAlertMessage = NSLocalizedString("TouchIdSettings.unavailableAlertMessage", value:"You have not setup Touch ID on this device. Go to Settings->Touch ID & Passcode to set it up now.", comment: "Touch ID unavailable alert message")
    }

    enum TouchIdSpendingLimit {
        static let title = NSLocalizedString("TouchIdSpendingLimit.title", value:"Touch ID Limit", comment: "Touch Id spending limit screen title")
        static let body = NSLocalizedString("TouchIdSpendingLimit.body", value:"You will be asked to enter you 6-Digit PIN for any send transaction over your Spending Limit, and every 48 hours since the last time you entered your 6-Digit PIN.", comment: "Touch ID spending limit screen body")
    }

    enum Settings {
        static let title = NSLocalizedString("Settings.title", value:"Settings", comment: "Settings title")
        static let importTile = NSLocalizedString("Settings.importTitle", value:"Import Wallet", comment: "Import wallet label")
        static let notifications = NSLocalizedString("Settings.notifications", value:"Notifications", comment: "Notifications label")
        static let touchIdLimit = NSLocalizedString("Settings.touchIdLimit", value:"Touch ID Spending Limit", comment: "Touch ID spending limit label")
        static let currency = NSLocalizedString("Settings.currency", value:"Default Currency", comment: "Default currency label")
        static let sync = NSLocalizedString("Settings.sync", value:"Sync Blockchain", comment: "Sync blockchain label")
        static let shareData = NSLocalizedString("Settings.shareData", value:"Share Anonymous Data", comment: "Share anonymous data label")
        static let earlyAccess = NSLocalizedString("Settings.earlyAccess", value:"Join Early Access", comment: "Join Early access label")
        static let about = NSLocalizedString("Settings.about", value:"About", comment: "About label")
    }

    enum About {
        static let title = NSLocalizedString("About.title", value:"About", comment: "About screen title")
        static let blog = NSLocalizedString("About.blog", value:"Blog", comment: "About screen blog label")
        static let twitter = NSLocalizedString("About.twitter", value:"Twitter", comment: "About screen twitter label")
        static let reddit = NSLocalizedString("About.reddit", value:"Reddit", comment: "About screen reddit label")
        static let terms = NSLocalizedString("About.terms", value:"Terms of Use", comment: "Terms of Use button label")
        static let privacy = NSLocalizedString("About.privacy", value:"Privacy Policy", comment: "Privay Policy button label")
        static let footer = NSLocalizedString("About.footer", value:"Made in North America. Version %@", comment: "About screen footer")
    }

    enum PushNotifications {
        static let title = NSLocalizedString("PushNotifications.title", value:"Notifications", comment: "Push notifications settings view title label")
        static let body = NSLocalizedString("PushNotifications.body", value:"Get notified when money you’ve received is available for spending.", comment: "Push notifications settings view body")
        static let label = NSLocalizedString("PushNotifications.label", value:"Push Notifications", comment: "Push notifications toggle switch label")
    }

    enum DefaultCurrency {
        static let title = NSLocalizedString("DefaultCurrency.title", value:"Default Currency", comment: "Default currency view title")
        static let rateLabel = NSLocalizedString("DefaultCurrency.rateLabel", value:"Exchange Rate", comment: "Exchange rate label")
    }

    enum SyncingView {
        static let header = NSLocalizedString("SyncingView.header", value:"Syncing", comment: "Syncing view header text")
        static let retry = NSLocalizedString("SyncingView.retry", value:"Retry", comment: "Retry button label")
    }

    enum ReScan {
        static let header = NSLocalizedString("ReScan.header", value:"Sync Blockchain", comment: "Sync Blockchain view header")
        static let subheader1 = NSLocalizedString("ReScan.subheader1", value:"Estimated time", comment: "Subheader label")
        static let subheader2 = NSLocalizedString("ReScan.subheader2", value:"When to Sync?", comment: "Subheader label")
        static let body1 = NSLocalizedString("ReScan.body1", value:"5-30 minutes", comment: "extimated time")
        static let body2 = NSLocalizedString("ReScan.body2", value:"If a transaction is taking much longer than its estimated time to complete.", comment: "Syncing explanation")
        static let body3 = NSLocalizedString("ReScan.body3", value:"If you believe a transaction is missing from your account history.", comment: "Syncing explanation")
        static let buttonTitle = NSLocalizedString("ReScan.buttonTitle", value:"Start Sync", comment: "Start Sync button label")
        static let footer = NSLocalizedString("ReScan.footer", value:"You will not be able to send money while syncing with the blockchain.", comment: "Sync blockchain view footer")
        static let alertTitle = NSLocalizedString("ReScan.alertTitle", value:"Sync with Blockchain?", comment: "Alert message title")
        static let alertMessage = NSLocalizedString("ReScan.alertMessage", value:"You will not be able to send money while syncing.", comment: "Alert message body")
        static let alertAction = NSLocalizedString("ReScan.alertAction", value:"Sync", comment: "Alert action button label")
    }

    enum ShareData {
        static let header = NSLocalizedString("ShareData.header", value:"Share Data?", comment: "Share data header")
        static let body = NSLocalizedString("ShareData.body", value:"Help improve Bread by sharing your annoymous data with us. This does not include any financial information. We respect your financial privacy.", comment: "Share data view body")
        static let toggleLabel = NSLocalizedString("ShareData.toggleLabel", value:"Share Anonymous Data?", comment: "Share data switch label.")
    }

    enum ConfirmPaperPhrase {
        static let word = NSLocalizedString("ConfirmPaperPhrase.word", value:"Word %@", comment: "Word label eg. Word 1, Word 2")
        static let label = NSLocalizedString("ConfirmPaperPhrase.label", value:"Prove you wrote down your paper key by answering the following questions.", comment: "Confirm paper phrase view label.")
    }

    enum StartPaperPhrase {
        static let body = NSLocalizedString("StartPaperPhrase.body", value:"Protect your wallet against theft and ensure you can recover your wallet after replacing your phone or updating its software. ", comment: "Paper key explanation text.")
        static let buttonTitle = NSLocalizedString("StartPaperPhrase.buttonTitle", value:"Write Down Paper Key", comment: "button label")
        static let againButtonTitle = NSLocalizedString("StartPaperPhrase.againButtonTitle", value:"Write Down Paper Key Again", comment: "button label")
        static let date = NSLocalizedString("StartPaperPhrase.date", value:"You last wrote down your paper key on %@", comment: "Argument is date")
    }

    enum WritePaperPhrase {
        static let instruction = NSLocalizedString("WritePaperPhrase.instruction", value:"Write down each word on a piece of paper and store it in a safe place.", comment: "")
        static let step = NSLocalizedString("WritePaperPhrase.step", value:"%d of %d", comment: "Eg. 1 of 3")
        static let next = NSLocalizedString("WritePaperPhrase.next", value:"Next", comment: "button label")
        static let previous = NSLocalizedString("WritePaperPhrase.previous", value:"Previous", comment: "button label")
    }

    enum TransactionDirection {
        static let to = NSLocalizedString("TransactionDirection.to", value:"to", comment: "Usage: sent transaction to")
        static let from = NSLocalizedString("TransactionDirection.from", value:"from", comment: "Usage: received transaction from")
        static let sent = NSLocalizedString("TransactionDirection.sent", value:"sent", comment: "Usage: sent transaction")
        static let received = NSLocalizedString("TransactionDirection.received", value:"received", comment: "Usage: received transaction")
        static let address = NSLocalizedString("TransactionDirection.address", value:"Address", comment: "")
    }

    enum RequestAnAmount {
        static let title = NSLocalizedString("RequestAnAmoutn.title", value:"Request an Amount", comment: "")
    }

    enum PinCreationView {
        static let setPinText = NSLocalizedString("PinCreationView.setPinText", value:"Set PIN", comment: "Set pin instruction")
        static let confirmPinText = NSLocalizedString("PinCreationView.confirmPinText", value:"Re-Enter PIN", comment: "Confirm pin instruction")
        static let wrongPinText = NSLocalizedString("PinCreationView.wrongPinText", value:"Wrong PIN, please try again", comment: "Wrong pin entered instruction")
        static let caption = NSLocalizedString("PinCreationView.caption", value:"Your PIN will be used to unlock your  Bread and send money.", comment: "Set Pin screen caption")
        static let body = NSLocalizedString("PinCreationView.body", value:"Write down your PIN and store it in a place you can access even if your phone is broken or lost.", comment: "Set Pin screen body")
    }

    enum Alerts {
        static let pinSet = NSLocalizedString("Alerts.pinSet", value:"PIN Set", comment: "Alert Header label")
        static let paperKeySet = NSLocalizedString("Alerts.paperKeySet", value:"Paper Key Set", comment: "Alert Header Label")
        static let sendSuccess = NSLocalizedString("Alerts.sendSuccess", value:"Send Confirmation", comment: "Send success alert header label")
        static let sendFailure = NSLocalizedString("Alerts.sendFailure", value:"Send failed", comment: "Send failure alert header label")

        static let pinSetSubheader = NSLocalizedString("Alerts.pinSetSubheader", value:"Use your PIN to login and send money.", comment: "Alert Subheader label")
        static let paperKeySetSubheader = NSLocalizedString("Alerts.paperKeySetSubheader", value:"Awesome!", comment: "Alert Subheader label")
        static let sendSuccessSubheader = NSLocalizedString("Alerts.sendSuccessSubheader", value:"Money Sent!", comment: "Send success alert subheader label")
        static let sendFailureSubheader = NSLocalizedString("Alerts.sendFailureSubheader", value:"Send Failed", comment: "Send failure alert subheader label")
    }

    enum MenuButton {
        static let security = NSLocalizedString("MenuButton.security", value:"Security Center", comment: "Menu button title")
        static let support = NSLocalizedString("MenuButton.support", value:"Support", comment: "Menu button title")
        static let settings = NSLocalizedString("MenuButton.settings", value:"Settings", comment: "Menu button title")
        static let lock = NSLocalizedString("MenuButton.lock", value:"Lock Wallet", comment: "Menu button title")
        static let buy = NSLocalizedString("MenuButton.buy", value:"Buy Bitcoin", comment: "Buy bitcoin title")
    }

    enum MenuViewController {
        static let modalTitle = NSLocalizedString("MenuViewController.modalTitle", value:"Menu", comment: "Menu modal title")
    }

    enum StartViewController {
        static let createButton = NSLocalizedString("MenuViewController.createButton", value:"Create New Wallet", comment: "button label")
        static let recoverButton = NSLocalizedString("MenuViewController.recoverButton", value:"Recover Wallet", comment: "button label")
    }

    enum AccessibilityLabels {
        static let close = NSLocalizedString("AccessibilityLabels.close", value:"Close", comment: "Close modal button accessibility label")
        static let faq = NSLocalizedString("AccessibilityLabels.faq", value: "Support Center", comment: "Support center accessibiliy label")
    }

    enum Watch {
        static let noWalletWarning = NSLocalizedString("Watch.noWalletWarning", value: "Open openwallet iPhone app to setup your wallet", comment: "No wallet warning for watch app")
    }

    enum Search {
        static let sent = NSLocalizedString("Search.sent", value: "sent", comment: "Sent filter label")
        static let received = NSLocalizedString("Search.received", value: "received", comment: "Received filter label")
        static let pending = NSLocalizedString("Search.pending", value: "pending", comment: "Pending filter label")
        static let complete = NSLocalizedString("Search.complete", value: "complete", comment: "Complete filter label")
    }

    enum Prompts {
        enum TouchId {
            static let title = NSLocalizedString("Prompts.TouchId.title", value: "Enable Touch Id", comment: "Enable touch Id prompt title")
            static let body = NSLocalizedString("Prompts.TouchId.body", value: "Tap here to enable Touch Id", comment: "Enable touch id prompt body")
        }
        enum PaperKey {
            static let title = NSLocalizedString("Prompts.PaperKey.title", value: "Paper Key not Saved", comment: "Paper Key not saved prompt title")
            static let body = NSLocalizedString("Prompts.PaperKey.body", value: "This wallet's paper key hasn't been written down. Tap here to view.", comment: "Paper Key not save prompt body")
        }
        enum UpgradePin {
            static let title = NSLocalizedString("Prompts.UpgradePin.title", value: "Upgrade PIN", comment: "Upgrade PIN prompt title.")
            static let body = NSLocalizedString("Prompts.UpgradePin.body", value: "Bread has updated to using a 6-digit PIN. Tap here to upgrade.", comment: "Upgrade PIN prompt body.")
        }
    }
}
