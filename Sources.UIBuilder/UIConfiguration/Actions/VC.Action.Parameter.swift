//
//  VC.Action.Parameter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 17.12.2025.
//

import Foundation

extension VC.Action {
    enum Parameter: Sendable, Hashable {
        case null
        case string(String)
        case bool(Bool)
        case int32(Int32)
        case uint32(UInt32)
        case double(Double)
    }
}
