//
//  Toggle.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.05.2024
//

import Foundation

package extension AdaptyViewConfiguration {
    struct Toggle: Sendable, Hashable {
        package let onActions: [Action]
        package let offActions: [Action]
        package let onCondition: StateCondition
        package let color: Mode<Color>?
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Toggle {
    static func create(
        onActions: [AdaptyViewConfiguration.Action],
        offActions: [AdaptyViewConfiguration.Action],
        onCondition: AdaptyViewConfiguration.StateCondition,
        color: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Color>? = nil
    ) -> Self {
        .init(
            onActions: onActions,
            offActions: offActions,
            onCondition: onCondition,
            color: color
        )
    }

    static func create(
        sectionId: String,
        onIndex: Int = 0,
        offIndex: Int = -1,
        color: AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Color>? = nil
    ) -> Self {
        .init(
            onActions: [.switchSection(id: sectionId, index: onIndex)],
            offActions: [.switchSection(id: sectionId, index: offIndex)],
            onCondition: .selectedSection(id: sectionId, index: onIndex),
            color: color
        )
    }
}
#endif
