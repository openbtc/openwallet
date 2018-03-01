//
//  BRAPIClient+Wallet.swift
//  openwallet
//
//  Created by Samuel Sutch on 4/2/17.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import Foundation

extension BRAPIClient {
    // Fetches the /v1/fee-per-kb endpoint
    func feePerKb(_ handler: @escaping (_ feePerKb: uint_fast64_t, _ error: String?) -> Void) {
        let req = URLRequest(url: url("/fee-per-kb"))
        let task = self.dataTaskWithRequest(req) { (data, response, err) -> Void in
            var feePerKb: uint_fast64_t = 0
            var errStr: String? = nil
            if err == nil {
                do {
                    let parsedObject: Any? = try JSONSerialization.jsonObject(
                        with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    if let top = parsedObject as? NSDictionary, let n = top["fee_per_kb"] as? NSNumber {
                        feePerKb = n.uint64Value
                    }
                } catch (let e) {
                    self.log("fee-per-kb: error parsing json \(e)")
                }
                if feePerKb == 0 {
                    errStr = "invalid json"
                }
            } else {
                self.log("fee-per-kb network error: \(String(describing: err))")
                errStr = "bad network connection"
            }
            handler(feePerKb, errStr)
        }
        task.resume()
    }
    
    func exchangeRates(_ handler: @escaping (_ rates: [Rate], _ error: String?) -> Void) {
        let request = URLRequest(url: url("/rates"))
        let task = dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil else { return handler([], error!.localizedDescription) }
            guard let data = data else { return handler([], "/rates returned no data") }
            guard let parsedData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else { return handler([], "/rates bad data format") }
            guard let dict = parsedData as? [String: Any] else { return handler([], "/rates didn't return a dictionary") }
            guard let array = dict["body"] as? [Any] else { return handler([], "/rates didn't return an array for body key") }
            handler(array.flatMap { Rate(data: $0) }, nil)
        }
        task.resume()
    }
    
    // MARK: push notifications
    
    func savePushNotificationToken(_ token: Data, pushNotificationType: String = "d") {
        var req = URLRequest(url: url("/me/push-devices"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        let reqJson = [
            "token": token.hexString,
            "service": "apns",
            "data": ["e": pushNotificationType]
            ] as [String : Any]
        do {
            let dat = try JSONSerialization.data(withJSONObject: reqJson, options: .prettyPrinted)
            req.httpBody = dat
        } catch (let e) {
            log("JSON Serialization error \(e)")
            return
        }
        dataTaskWithRequest(req as URLRequest, authenticated: true, retryCount: 0) { (dat, resp, er) in
            let dat2 = String(data: dat ?? Data(), encoding: .utf8)
            self.log("save push token resp: \(String(describing: resp)) data: \(String(describing: dat2))")
            }.resume()
    }
}
