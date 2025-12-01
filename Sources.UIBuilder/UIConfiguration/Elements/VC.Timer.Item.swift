//
//  VC.Timer.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

package extension VC.Timer {
    struct Item: Sendable, Hashable {
        package let from: TimeInterval
        package let value: VC.RichText
    }
}

#if DEBUG
package extension VC.Timer.Item {
    static func create(
        from: TimeInterval,
        value: VC.RichText
    ) -> Self {
        .init(
            from: from,
            value: value
        )
    }
}
#endif
