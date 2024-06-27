//
//  Button.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Button {
        package let actions: [ButtonAction]
        package let normalState: AdaptyUI.Element
        package let selectedState: AdaptyUI.Element?
        package let selectedCondition: StateCondition?
    }
}

#if DEBUG
    package extension AdaptyUI.Button {
        static func create(
            actions: [AdaptyUI.ButtonAction],
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
