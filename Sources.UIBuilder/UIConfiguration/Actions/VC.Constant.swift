//
//  VC.Constant.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 17.12.2025.
//

import Foundation

extension VC {
    typealias Constants = [String: Constant]

    enum Constant: Sendable, Hashable {
        case null
        case string(String)
        case bool(Bool)
        case int32(Int32)
        case uint32(UInt32)
        case double(Double)
        case object([String: Self])
    }
}

extension VC.Constant {
    var asOptional: Self? {
        guard case .null = self else { return nil }
        return self
    }
}
