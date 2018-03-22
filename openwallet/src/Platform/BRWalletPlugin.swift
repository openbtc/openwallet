//
//  BRWalletPlugin.swift
//  BreadWallet
//
//  Created by Samuel Sutch on 2/18/16.
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
import BRCore


class BRWalletPlugin: BRHTTPRouterPlugin, BRWebSocketClient {
    var sockets = [String: BRWebSocket]()
    let walletManager: WalletManager
    let store: Store
 
    init(walletManager: WalletManager, store: Store) {
        self.walletManager = walletManager
        self.store = store
    }
    
    func announce(_ json: [String: Any]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
            for sock in sockets {
                sock.1.send(String(jsonString))
            }
        } else {
            print("[BRWalletPlugin] announce() could not encode payload: \(json)")
        }
    }
 
    func hook(_ router: BRHTTPRouter) {
        router.websocket("/_wallet/_socket", client: self)
        
        let noteCenter = NotificationCenter.default
        noteCenter.addObserver(forName: NSNotification.Name.WalletSyncStartedNotification,
                               object: nil, queue: nil) { (note) in
            self.announce(["type": "sync_started"])
        }
        noteCenter.addObserver(forName: NSNotification.Name.WalletSyncFailedNotification,
                               object: nil, queue: nil) { (note) in
            self.announce(["type": "sync_failed"])
        }
        noteCenter.addObserver(forName: NSNotification.Name.WalletSyncSucceededNotification,
                               object: nil, queue: nil) { (note) in
            self.announce(["type": "sync_finished"])
        }
        noteCenter.addObserver(forName: NSNotification.Name.WalletTxStatusUpdateNotification,
                               object: nil, queue: nil) { (note) in
            self.announce(["type": "tx_status"])
        }
        noteCenter.addObserver(forName: NSNotification.Name.WalletTxRejectedNotification,
                               object: nil, queue: nil) { (note) in
            self.announce(["type": "tx_status"])
        }
        noteCenter.addObserver(forName: NSNotification.Name.WalletBalanceChangedNotification,
                               object: nil, queue: nil) { (note) in
            if let wallet = self.walletManager.wallet {
                self.announce(["type": "balance_changed", "balance": Int(wallet.balance)])
            }
        }
 
        router.get("/_wallet/info") { (request, match) -> BRHTTPResponse in
            return try BRHTTPResponse(request: request, code: 200, json: self.walletInfo())
        }
 
        router.get("/_wallet/format") { (request, match) -> BRHTTPResponse in
            if let amounts = request.query["amount"] , amounts.count > 0 {
                let amount = amounts[0]
                var intAmount: Int64 = 0
                if amount.contains(".") { // assume full bitcoins
                    if let x = Float(amount) {
                        intAmount = Int64(x * 100000000.0)
                    }
                } else {
                    if let x = Int64(amount) {
                        intAmount = x
                    }
                }
                return try BRHTTPResponse(request: request, code: 200, json: self.currencyFormat(intAmount))
            } else {
                return BRHTTPResponse(request: request, code: 400)
            }
        }
        
        // POST /_wallet/sign_bitid
        //
        // Sign a message using the user's BitID private key. Calling this WILL trigger authentication
        //
        // Request body: application/json
        //      {
        //          "prompt_string": "Sign in to My Service", // shown to the user in the authentication prompt
        //          "string_to_sign": "https://bitid.org/bitid?x=2783408723", // the string to sign
        //          "bitid_url": "https://bitid.org/bitid", // the bitid url for deriving the private key
        //          "bitid_index": "0" // the bitid index as a string (just pass "0")
        //      }
        //
        // Response body: application/json
        //      {
        //          "signature": "oibwaeofbawoefb" // base64-encoded signature
        //      }
        router.post("/_wallet/sign_bitid") { (request, match) -> BRHTTPResponse in
            guard let cts = request.headers["content-type"] , cts.count == 1 && cts[0] == "application/json" else {
                return BRHTTPResponse(request: request, code: 400)
            }
            guard let data = request.body(),
                      let j = try? JSONSerialization.jsonObject(with: data, options: []),
                      let json = j as? [String: String],
                      let stringToSign = json["string_to_sign"],
                      let bitidUrlString = json["bitid_url"],
                      let bitidUrl = URL(string: bitidUrlString),
                      let bii = json["bitid_index"],
                      let bitidIndex = Int(bii) else {
                return BRHTTPResponse(request: request, code: 400)
            }
            let asyncResp = BRHTTPResponse(async: request)
            DispatchQueue.main.sync {
                CFRunLoopPerformBlock(RunLoop.main.getCFRunLoop(), CFRunLoopMode.commonModes.rawValue) {
                    let prompt = bitidUrl.host ?? bitidUrl.description
                    self.store.trigger(name: .authenticateForBitId(prompt, { authenticationSuccess in
                        if authenticationSuccess {
                            let response = self.walletManager.buildBitIdResponse(stringToSign: stringToSign,
                                                                                 url: bitidUrl.host ?? bitidUrl.absoluteString,
                                                                                 index: bitidIndex )
                            guard let json = response.1 else {
                                request.queue.async { asyncResp.provide(response.0) }
                                return
                            }
                            request.queue.async {
                                asyncResp.provide(response.0, json: json)
                            }
                        }
                    }))
                }
            }
            return asyncResp
        }
    }
    
    // MARK: - basic wallet functions
    
    func walletInfo() -> [String: Any] {
        var d = [String: Any]()
        d["no_wallet"] = walletManager.noWallet
        // FIXME: convert BRAddress to String
//        if let wallet = walletManager.wallet {
//            var addr = BRWalletReceiveAddress(wallet.ptr)
//            d["receive_address"] = String.fromCString(addr)
//        }
        return d
    }
    
    func currencyFormat(_ amount: Int64) -> [String: Any] {
        // FIXME: when currency formatting is added back in
        let d = [String: Any]()
//        d["local_currency_amount"] = manager.localCurrencyString(forAmount: Int64(amount))
//        d["currency_amount"] = manager.string(forAmount: amount)
        return d
    }
    
    // MARK: - socket handlers
    
    func sendWalletInfo(_ socket: BRWebSocket) {
        var d = self.walletInfo()
        d["type"] = "wallet"
        if let jdata = try? JSONSerialization.data(withJSONObject: d, options: []),
            let jstring = NSString(data: jdata, encoding: String.Encoding.utf8.rawValue) {
            socket.send(String(jstring))
        }
    }
    
    func socketDidConnect(_ socket: BRWebSocket) {
        print("WALLET CONNECT \(socket.id)")
        sockets[socket.id] = socket
        sendWalletInfo(socket)
    }
    
    func socketDidDisconnect(_ socket: BRWebSocket) {
        print("WALLET DISCONNECT \(socket.id)")
        sockets.removeValue(forKey: socket.id)
    }
    
    func socket(_ socket: BRWebSocket, didReceiveText text: String) {
        print("WALLET RECV \(text)")
        socket.send(text)
    }
    
    public func socket(_ socket: BRWebSocket, didReceiveData data: Data) {
        // nothing to do here
    }
}
