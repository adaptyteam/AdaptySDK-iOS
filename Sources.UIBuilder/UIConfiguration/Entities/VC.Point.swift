//
//  VC.Point.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

package extension VC {
    struct Point: Sendable, Hashable {
        package let x: Double
        package let y: Double
    }
}

package extension VC.Point {
    var isZero: Bool {
        x == 0.0 && y == 0.0
    }
}
