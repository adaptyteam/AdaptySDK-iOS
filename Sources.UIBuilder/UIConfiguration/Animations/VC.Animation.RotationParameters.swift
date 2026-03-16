//
//  VC.Animation.RotationParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.03.2025
//

import Foundation

extension VC.Animation {
    struct RotationParameters: Sendable, Hashable {
        let angle: Range<Double>
        let anchor: VC.Point
    }
}
