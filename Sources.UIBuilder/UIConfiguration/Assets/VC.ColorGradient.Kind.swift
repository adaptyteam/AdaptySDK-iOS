//
//  VC.ColorGradient.Kind.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension VC.ColorGradient {
    enum Kind: Sendable, Equatable {
        case linear
        case conic
        case radial
    }
}
