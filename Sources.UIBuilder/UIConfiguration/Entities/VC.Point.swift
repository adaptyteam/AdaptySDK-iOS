//
//  VC.Point.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension VC {
    struct Point: Sendable, Hashable {
        let x: Double
        let y: Double
    }
}

extension VC.Point {
    @inlinable
    var isZero: Bool {
        x == 0.0 && y == 0.0
    }
}
