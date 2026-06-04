//
//  VC.Condition.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.06.2026.
//

import Foundation

extension VC {
    enum Condition: Sendable {
        case availableWidth(min: Double?, max: Double?)
        case availableHeight(min: Double?, max: Double?)
        case screenWidth(min: Double?, max: Double?)
        case screenHeight(min: Double?, max: Double?)
        case orientation(VC.Orientation)
        case `true`
    }
}

