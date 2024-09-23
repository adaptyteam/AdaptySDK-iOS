//
//  Button.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Button: Sendable, Hashable {
        package let actions: [ActionAction]
        package let normalState: Element
        package let selectedState: Element?
        package let selectedCondition: StateCondition?
    }
}

#if DEBUG
    package extension AdaptyUI.Button {
        static func create(
            actions: [AdaptyUI.ActionAction],
            normalState: AdaptyUI.Element,
            selectedState: AdaptyUI.Element? = nil,
            selectedCondition: AdaptyUI.StateCondition? = nil
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
