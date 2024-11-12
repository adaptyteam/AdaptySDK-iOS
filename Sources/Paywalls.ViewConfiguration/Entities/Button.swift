//
//  Button.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUICore {
    package struct Button: Sendable, Hashable {
        package let actions: [ActionAction]
        package let normalState: Element
        package let selectedState: Element?
        package let selectedCondition: StateCondition?
    }
}

#if DEBUG
    package extension AdaptyUICore.Button {
        static func create(
            actions: [AdaptyUICore.ActionAction],
            normalState: AdaptyUICore.Element,
            selectedState: AdaptyUICore.Element? = nil,
            selectedCondition: AdaptyUICore.StateCondition? = nil
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
