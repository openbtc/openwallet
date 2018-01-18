//
//  Trackable.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-19.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import Foundation

protocol Trackable {
    func saveEvent(_ eventName: String)
    func saveEvent(_ eventName: String, attributes: [String: String])
}

extension Trackable {
    func saveEvent(_ eventName: String) {
        EventManager.shared.saveEvent(eventName)
    }

    func saveEvent(_ eventName: String, attributes: [String: String]) {
        EventManager.shared.saveEvent(eventName, attributes: attributes)
    }
}

fileprivate class EventManager {
    static let shared = EventManager()

    func saveEvent(_ eventName: String) {

    }

    func saveEvent(_ eventName: String, attributes: [String: String]) {

    }
}
