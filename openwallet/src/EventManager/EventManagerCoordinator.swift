//
//  EventManagerCoordinator.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-20.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import Foundation

protocol EventManagerCoordinator {
    func startEventManager()
    func syncEventManager(completion: @escaping () -> Void)
    func acquireEventManagerUserPermissions(callback: () -> Void)
}
