//
//  Button.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Button {
        package let action: ButtonAction
        package let normalState: AdaptyUI.Element
        package let selectedState: AdaptyUI.Element?
    }
}

#if DEBUG
    package extension AdaptyUI.Button {
        static func create(
            action: AdaptyUI.ButtonAction,
            normalState: AdaptyUI.Element,
            selectedState: AdaptyUI.Element? = nil
        ) -> Self {
            .init(
                action: action,
                normalState: normalState,
                selectedState: selectedState
            )
        }
    }
#endif
