//
//  VS.StringIdentifierOrText.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.10.2026.
//

import Foundation

extension VS {
    struct StringIdentifierOrText: Sendable {
        let stringId: VC.StringIdentifier?
        let text: String?

        init?(stringId: VC.StringIdentifier?, text: String?) {
            if stringId == nil && text == nil {
                return nil
            }
            self.stringId = stringId
            self.text = text
        }
    }
}
