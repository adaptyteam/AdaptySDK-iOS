//
//  VC.StringReference.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 13.01.2026.
//

import Foundation

extension VC {
    enum StringReference: Sendable, Hashable {
        case stringId(StringIdentifier, [String: TagValue]?)
        case variable(Variable)
        case product(Product)
    }
}
