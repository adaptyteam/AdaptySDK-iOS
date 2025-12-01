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

package extension VC.Point {
    static let zero = Self(x: 0.0, y: 0.0)
    static let one = Self(x: 1.0, y: 1.0)
    static let center = Self(x: 0.5, y: 0.5)
}

#if DEBUG
package extension VC.Point {
    static func create(
        x: Double = 0.0,
        y: Double = 0.0
    ) -> Self {
        .init(
            x: x,
            y: y
        )
    }
}
#endif
