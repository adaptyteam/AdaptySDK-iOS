//
//  VC.EdgeInsets.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension VC {
    struct EdgeInsets: Sendable, Equatable {
        let leading: Unit
        let top: Unit
        let trailing: Unit
        let bottom: Unit
    }
}

extension VC.EdgeInsets {
    init(same: VC.Unit) {
        self.init(
            leading: same,
            top: same,
            trailing: same,
            bottom: same
        )
    }

    @inlinable
    var isZero: Bool {
        leading.isZero
            && top.isZero
            && trailing.isZero
            && bottom.isZero
    }

    @inlinable
    var isSame: Bool {
        (bottom == top)
            && (leading == trailing)
            && (top == trailing)
    }
}
