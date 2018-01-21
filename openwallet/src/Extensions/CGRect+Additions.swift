//
//  CGRect+Additions.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-11-29.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}
