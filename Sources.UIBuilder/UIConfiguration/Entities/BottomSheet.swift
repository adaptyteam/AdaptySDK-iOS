//
//  BottomSheet.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyUIConfiguration {
    package struct BottomSheet: Sendable, Hashable {
        package let content: Element
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.BottomSheet {
    static func create(
        content: AdaptyUIConfiguration.Element
    ) -> Self {
        .init(
            content: content
        )
    }
}
#endif
