//
//  VC.BottomSheet.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

package extension VC {
    struct BottomSheet: Sendable, Hashable {
        package let content: Element
    }
}

#if DEBUG
package extension VC.BottomSheet {
    static func create(
        content: VC.Element
    ) -> Self {
        .init(
            content: content
        )
    }
}
#endif
