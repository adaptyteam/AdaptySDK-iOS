//
//  VC.EdgeInsets.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension VC {
    struct EdgeInsets: Sendable, Hashable {
        package let leading: VC.Unit
        package let top: VC.Unit
        package let trailing: VC.Unit
        package let bottom: VC.Unit
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

    var isSameRadius: Bool {
        (bottom == top)
            && (leading == trailing)
            && (top == trailing)
    }
}

package extension VC.EdgeInsets {
    static let zero = Self(same: .zero)
}

#if DEBUG
package extension VC.EdgeInsets {
    static func create(
        same: VC.Unit = .zero
    ) -> Self {
        .init(same: same)
    }

    static func create(
        leading: VC.Unit = .zero,
        top: VC.Unit = .zero,
        trailing: VC.Unit = .zero,
        bottom: VC.Unit = .zero
    ) -> Self {
        .init(
            leading: leading,
            top: top,
            trailing: trailing,
            bottom: bottom
        )
    }
}
#endif
