//
//  State.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-10-24.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import Foundation

struct State {
    let count: Int
    let isStartFlowVisible: Bool
    let pinCreationStep: PinCreationStep
}

extension State {
    static var initial: State {
        return State(   count:              0,
                        isStartFlowVisible: false,
                        pinCreationStep:    .none)
    }
}

enum PinCreationStep {
    case none
    case start
    case confirm
    case save
}
