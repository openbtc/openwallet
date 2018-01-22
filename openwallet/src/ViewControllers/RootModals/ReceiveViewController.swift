//
//  ReceiveViewController.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-30.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

class ReceiveViewController: UIViewController {

}

extension ReceiveViewController: ModalDisplayable {
    var modalTitle: String {
        return NSLocalizedString("Receive", comment: "Receive modal title")
    }

    var modalSize: CGSize {
        return CGSize(width: view.frame.width, height: 400.0)
    }

    var isFaqHidden: Bool {
        return false
    }
}
