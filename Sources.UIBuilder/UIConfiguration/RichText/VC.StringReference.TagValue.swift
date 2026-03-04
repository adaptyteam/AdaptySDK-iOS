//
//  VC.StringReference.TagValue.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.03.2026.
//

import Foundation

package extension VC.StringReference {
    enum TagValue: Sendable, Hashable {
        case value(String)
        case variable(VC.Variable)
    }
}
