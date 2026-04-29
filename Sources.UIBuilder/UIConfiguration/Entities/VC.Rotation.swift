//
//  VC.Rotation.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.03.2026.
//

import Foundation

extension VC {
    struct Rotation: Sendable, Equatable {
        let angle: Double
        let anchor: VC.Point
    }
}

extension VC.Rotation {
    @inlinable
    var isZero: Bool {
        angle == 0
    }
}

