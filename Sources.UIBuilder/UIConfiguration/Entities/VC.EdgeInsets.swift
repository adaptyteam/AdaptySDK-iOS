//
//  VC.EdgeInsets.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension VC {
    struct EdgeInsets: Sendable, Hashable {
        package let leading: Unit
        package let top: Unit
        package let trailing: Unit
        package let bottom: Unit
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

    var isZero: Bool {
        leading.isZero
            && top.isZero
            && trailing.isZero
            && bottom.isZero
    }

    var isSame: Bool {
        (bottom == top)
            && (leading == trailing)
            && (top == trailing)
    }
}
