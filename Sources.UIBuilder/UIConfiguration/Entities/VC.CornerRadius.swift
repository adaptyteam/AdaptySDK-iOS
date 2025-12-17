//
//  VC.CornerRadius.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

package extension VC {
    struct CornerRadius: Sendable, Hashable {
        package let topLeading: Double
        package let topTrailing: Double
        package let bottomTrailing: Double
        package let bottomLeading: Double
    }
}

extension VC.CornerRadius {
    init(same value: Double) {
        self.init(
            topLeading: value,
            topTrailing: value,
            bottomTrailing: value,
            bottomLeading: value
        )
    }

    var isZero: Bool {
        topLeading.isZero
            && topTrailing.isZero
            && bottomTrailing.isZero
            && bottomLeading.isZero
    }

    var isSameRadius: Bool {
        (topLeading == topTrailing)
            && (bottomLeading == bottomTrailing)
            && (topLeading == bottomLeading)
    }
}
