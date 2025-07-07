//
//  Button.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyViewConfiguration {
    package struct Button: Sendable, Hashable {
        package let actions: [ActionAction]
        package let normalState: Element
        package let selectedState: Element?
        package let selectedCondition: StateCondition?
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Button {
    static func create(
        actions: [AdaptyViewConfiguration.ActionAction],
        normalState: AdaptyViewConfiguration.Element,
        selectedState: AdaptyViewConfiguration.Element? = nil,
        selectedCondition: AdaptyViewConfiguration.StateCondition? = nil
    ) -> Self {
        .init(
            actions: actions,
            normalState: normalState,
            selectedState: selectedState,
            selectedCondition: selectedCondition
        )
    }
}
#endif
