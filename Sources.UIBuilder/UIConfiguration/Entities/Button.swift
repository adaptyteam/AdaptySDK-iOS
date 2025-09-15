//
//  Button.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUIConfiguration {
    package struct Button: Sendable, Hashable {
        package let actions: [Action]
        package let normalState: Element
        package let selectedState: Element?
        package let selectedCondition: StateCondition?
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.Button {
    static func create(
        actions: [AdaptyUIConfiguration.Action],
        normalState: AdaptyUIConfiguration.Element,
        selectedState: AdaptyUIConfiguration.Element? = nil,
        selectedCondition: AdaptyUIConfiguration.StateCondition? = nil
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
