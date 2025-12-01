//
//  VC.Box.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

package extension VC {
    struct Box: Sendable, Hashable {
        package let width: Length?
        package let height: Length?
        package let horizontalAlignment: HorizontalAlignment
        package let verticalAlignment: VerticalAlignment
        package let content: Element?
    }
}

extension VC.Box {
    static let `default` = (
        horizontalAlignment: VC.HorizontalAlignment.center,
        verticalAlignment: VC.VerticalAlignment.center
    )
}

#if DEBUG
package extension VC.Box {
    static func create(
        width: Length? = nil,
        height: Length? = nil,
        horizontalAlignment: VC.HorizontalAlignment = `default`.horizontalAlignment,
        verticalAlignment: VC.VerticalAlignment = `default`.verticalAlignment,
        content: VC.Element? = nil
    ) -> Self {
        .init(
            width: width,
            height: height,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment,
            content: content
        )
    }
}
#endif
