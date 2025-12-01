//
//  VC.Offset.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension VC {
    struct Offset: Sendable, Hashable {
        package let x: Unit
        package let y: Unit
    }
}

package extension VC.Offset {
    var isZero: Bool {
        x.isZero && y.isZero
    }
}

package extension VC.Offset {
    static let zero = Self(x: .zero, y: .zero)
    static let one = Self(x: .point(1.0), y: .point(1.0))
}

#if DEBUG
package extension VC.Offset {
    static func create(
        x: VC.Unit = .zero,
        y: VC.Unit = .zero
    ) -> Self {
        .init(
            x: x,
            y: y
        )
    }
}
#endif
