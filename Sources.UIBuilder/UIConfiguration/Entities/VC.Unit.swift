//
//  VC.Unit.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension VC {
    enum Unit: Sendable, Hashable {
        case point(Double)
        case screen(Double)
        case safeArea(SafeArea)
    }
}

extension VC.Unit {
    var isZero: Bool {
        switch self {
        case let .point(value), let .screen(value):
            value == 0.0
        default:
            false
        }
    }
}

package extension VC.Unit {
    static let zero = Self.point(0.0)
}
