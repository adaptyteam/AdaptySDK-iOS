//
//  VC.StringReference.TagValue.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.03.2026.
//

import Foundation

extension VC.StringReference {
    enum TagValue: Sendable {
        case value(String)
        case variable(VC.Variable)
    }
}
