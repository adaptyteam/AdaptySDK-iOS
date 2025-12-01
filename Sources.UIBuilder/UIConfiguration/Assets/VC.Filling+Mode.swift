//
//  VC.Filling+Mode.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

package extension VC.Mode<VC.Filling> {
    var hasColorGradient: Bool {
        switch self {
        case .same(.solidColor), .different(light: .solidColor, dark: .solidColor):
            false
        default:
            true
        }
    }

    var asSolidColor: VC.Mode<VC.Color>? {
        switch self {
        case let .same(.solidColor(value)):
            .same(value)
        case let .different(.solidColor(light), .solidColor(dark)):
            .different(light: light, dark: dark)
        default:
            nil
        }
    }
}
