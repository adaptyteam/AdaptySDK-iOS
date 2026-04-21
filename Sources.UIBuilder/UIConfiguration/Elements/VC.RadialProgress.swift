//
//  VC.RadialProgress.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.04.2026.
//

import Foundation

extension VC {
    struct RadialProgress: Sendable, Hashable {
        let thickness: Double?
        let sweepAngle: Double
        let startAngle: Double
        let clockwise: Bool
        let roundedCaps: Bool
        let asset: AssetReference
        let clip: Bool
        let value: Variable
        let transition: Transition
        let actions: [Action]
    }
}

