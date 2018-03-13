//
//  WatchDataManager.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2017-04-27.
//  Copyright © 2017 openwallet LLC. All rights reserved.
//

import WatchKit
import WatchConnectivity

enum WalletStatus {
    case unknown
    case hasSetup
    case notSetup
}

extension Notification.Name {
    static let ApplicationDataDidUpdateNotification = NSNotification.Name("ApplicationDataDidUpdateNotification")
    static let WalletStatusDidChangeNotification = NSNotification.Name("WalletStatusDidChangeNotification")
    static let WalletTxReceiveNotification = NSNotification.Name("WalletTxReceiveNotification")
}

class WatchDataManager : NSObject {

    static let applicationContextDataFileName = "applicationContextData.txt"

    let session = WCSession.default()
    var data: WatchData?
    let timerFireInterval : TimeInterval = 7; // have iphone app sync with peer every 7 seconds

    var timer : Timer?
    var walletStatus: WalletStatus {
        guard let data = data else { return .unknown }
        return data.hasWallet ? .hasSetup : .notSetup
    }

    static let shared = WatchDataManager()

    private override init() {
        super.init()
        session.delegate = self
        session.activate()
    }

    func setupTimer() {
        destroyTimer()
        let weakTimerTarget = BRAWWeakTimerTarget(initTarget: self,
                                                  initSelector: #selector(WatchDataManager.requestAllData))
        timer = Timer.scheduledTimer(timeInterval: timerFireInterval, target: weakTimerTarget,
                                     selector: #selector(BRAWWeakTimerTarget.timerDidFire),
                                     userInfo: nil, repeats: true)
    }

    func destroyTimer() {
        if let currentTimer : Timer = timer {
            currentTimer.invalidate();
            timer = nil
        }
    }

    func requestAllData() {
        guard session.isReachable else {
            print("not reachable")
            return
        }

        let message = [
            AW_SESSION_REQUEST_TYPE: AWSessionRequestType.fetchData.rawValue,
            AW_SESSION_REQUEST_DATA_TYPE_KEY: AWSessionRequestDataType.applicationContextData.rawValue
        ]

        print("request: \(message)")
        session.sendMessage(message, replyHandler: { replyMessage in
            //print("reply: \(replyMessage)")
            if let data = replyMessage[AW_SESSION_RESPONSE_KEY] as? [String: Any] {
                let newData = WatchData(data: data)
                let previousAppleWatchData = self.data
                let previousWalletStatus = self.walletStatus
                self.data = newData
                if previousAppleWatchData != self.data {
                    self.archiveData(newData)
                    NotificationCenter.default.post(
                        name: .ApplicationDataDidUpdateNotification, object: nil)
                }
                if self.walletStatus != previousWalletStatus {
                    NotificationCenter.default.post(
                        name: .WalletStatusDidChangeNotification, object: nil)
                }
            }
        }, errorHandler: { error in
            print("request all data error: \(error)")
        })
    }

    func archiveData(_ appleWatchData: WatchData){
        //TODO - archive data
        //try? NSKeyedArchiver.archivedData(withRootObject: appleWatchData).write(to: dataFilePath, options: [.atomic])
    }

    func unarchiveData() {
        if let newData = try? Data(contentsOf: dataFilePath) {
            data = NSKeyedUnarchiver.unarchiveObject(with: newData) as? WatchData
        }
    }

    lazy var dataFilePath: URL = {
        let filemgr = FileManager.default
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        return URL(fileURLWithPath: docsDir).appendingPathComponent(applicationContextDataFileName)
    }()

}

extension WatchDataManager : WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activation did complete")
        requestAllData()
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("did receive application context: \(applicationContext)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("did receive message: \(message)")
    }
}
