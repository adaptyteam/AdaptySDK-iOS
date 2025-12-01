//
//  VC.Filling.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.06.2023
//

import Foundation

package extension VC {
    enum Filling: Sendable, Hashable {
        case solidColor(VC.Color)
        case colorGradient(VC.ColorGradient)
    }
}

package extension VC.Filling {
    var asSolidColor: VC.Color? {
        switch self {
        case let .solidColor(value): value
        default: nil
        }
    }
}

extension VC.Filling {
    static let `default` = Self.solidColor(VC.Color.black)
}
