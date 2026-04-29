//
//  VC.CornerRadius.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

extension VC {
    struct CornerRadius: Sendable, Equatable {
        let topLeading: Double
        let topTrailing: Double
        let bottomTrailing: Double
        let bottomLeading: Double
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

    @inlinable
    var isZero: Bool {
        topLeading.isZero
            && topTrailing.isZero
            && bottomTrailing.isZero
            && bottomLeading.isZero
    }

    @inlinable
    var isSameRadius: Bool {
        (topLeading == topTrailing)
            && (bottomLeading == bottomTrailing)
            && (topLeading == bottomLeading)
    }
}
