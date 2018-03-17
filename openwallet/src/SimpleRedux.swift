//
//  SimpleRedux.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-10-21.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

typealias Reducer = (State) -> State
typealias Selector = (_ oldState: State, _ newState: State) -> Bool

protocol Action {
    var reduce: Reducer { get }
}

//We need reference semantics for Subscribers, so they are restricted to classes
protocol Subscriber: class {}

extension Subscriber {
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

typealias StateUpdatedCallback = (State) -> Void

struct Subscription {
    let selector: ((_ oldState: State, _ newState: State) -> Bool)
    let callback: (State) -> Void
}

struct Trigger {
    let name: TriggerName
    let callback: (TriggerName?) -> Void
}

enum TriggerName {
    case presentFaq(String)
    case registerForPushNotificationToken
    case retrySync
    case rescan
    case lock
    case promptTouchId
    case promptPaperKey
    case promptUpgradePin
} //NB : remember to add to triggers to == fuction below

extension TriggerName : Equatable {}

func ==(lhs: TriggerName, rhs: TriggerName) -> Bool {
    switch (lhs, rhs) {
    case (.presentFaq(_), .presentFaq(_)):
        return true
    case (.registerForPushNotificationToken, .registerForPushNotificationToken):
        return true
    case (.retrySync, .retrySync):
        return true
    case (.rescan, .rescan):
        return true
    case (.lock, .lock):
        return true
    case (.promptTouchId, .promptTouchId):
        return true
    case (.promptPaperKey, .promptPaperKey):
        return true
    case (.promptUpgradePin, .promptUpgradePin):
        return true
    default:
        return false
    }
}

class Store {

    //MARK: - Public
    init() {
        addPasteboardSubscriptions()
    }

    func perform(action: Action) {
        state = action.reduce(state)
    }

    func trigger(name: TriggerName) {
        triggers
            .flatMap { $0.value }
            .filter { $0.name == name }
            .forEach { $0.callback(name) }
    }

    //Subscription callback is immediately called with current State value on subscription
    //and then any time the selected value changes
    func subscribe(_ subscriber: Subscriber, selector: @escaping Selector, callback: @escaping (State) -> Void) {
        lazySubscribe(subscriber, selector: selector, callback: callback)
        callback(state)
    }

    //Same as subscribe(), but doesn't call the callback with current state upon subscription
    func lazySubscribe(_ subscriber: Subscriber, selector: @escaping Selector, callback: @escaping (State) -> Void) {
        let key = subscriber.hashValue
        let subscription = Subscription(selector: selector, callback: callback)
        if subscriptions[key] != nil {
            subscriptions[key]?.append(subscription)
        } else {
            subscriptions[key] = [subscription]
        }
    }

    func subscribe(_ subscriber: Subscriber, name: TriggerName, callback: @escaping (TriggerName?) -> Void) {
        let key = subscriber.hashValue
        let trigger = Trigger(name: name, callback: callback)
        if triggers[key] != nil {
            triggers[key]?.append(trigger)
        } else {
            triggers[key] = [trigger]
        }
    }

    func unsubscribe(_ subscriber: Subscriber) {
        subscriptions.removeValue(forKey: subscriber.hashValue)
        triggers.removeValue(forKey: subscriber.hashValue)
    }

    //MARK: - Private
    private(set) var state = State.initial {
        didSet {
            subscriptions
                .flatMap { $0.value } //Retreive all subscriptions (subscriptions is a dictionary)
                .filter { $0.selector(oldValue, state) }
                .forEach { $0.callback(state) }
        }
    }

    private var subscriptions: [Int: [Subscription]] = [:]
    private var triggers: [Int: [Trigger]] = [:]

    private func addPasteboardSubscriptions() {
        NotificationCenter.default.addObserver(forName: .UIPasteboardChanged, object: nil, queue: nil, using: { note in
            self.perform(action: Pasteboard.refresh())
        })

        NotificationCenter.default.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: OperationQueue(), using: { note in
            self.perform(action: Pasteboard.refresh())
        })
    }
}
