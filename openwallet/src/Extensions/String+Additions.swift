//
//  String+Additions.swift
//  openwallet
//
//  Created by Adrian Corscadden on 2016-12-12.
//  Copyright © 2016 openwallet LLC. All rights reserved.
//

import UIKit

extension String {
    var isValidAddress: Bool {
        guard lengthOfBytes(using: .utf8) > 0 else { return false }
        #if Testnet
            return true
        #endif
        if characters.first == "1" || characters.first == "3" {
            return true
        } else {
            return false
        }
    }

    var sanitized: String {
        return applyingTransform(.toUnicodeName, reverse: false) ?? ""
    }

    func ltrim(_ chars: Set<Character>) -> String {
        if let index = self.characters.index(where: {!chars.contains($0)}) {
            return self[index..<self.endIndex]
        } else {
            return ""
        }
    }
}

private let startTag = "<b>"
private let endTag = "</b>"

//Convert string with <b> tags to attributed string
extension String {
    var tagsRemoved: String {
        return replacingOccurrences(of: startTag, with: "").replacingOccurrences(of: endTag, with: "")
    }

    var attributedStringForTags: NSAttributedString {
        let output = NSMutableAttributedString()
        let scanner = Scanner(string: self)
        let endCount = tagsRemoved.utf8.count
        var i = 0
        while output.string.utf8.count < endCount || i < 50 {
            var regular: NSString?
            var bold: NSString?
            scanner.scanUpTo(startTag, into: &regular)
            scanner.scanUpTo(endTag, into: &bold)
            if let regular = regular {
                output.append(NSAttributedString(string: (regular as String).tagsRemoved, attributes: UIFont.regularAttributes))
            }
            if let bold = bold {
                output.append(NSAttributedString(string: (bold as String).tagsRemoved, attributes: UIFont.boldAttributes))
            }
            i += 1
        }
        return output
    }
}
