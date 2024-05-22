//
//  Button.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Button {
        static let defaultIsSelected = false
        package let action: ButtonAction?
        package let isSelected: Bool
        package let normalState: AdaptyUI.Element?
        package let selectedState: AdaptyUI.Element?
    }
}

#if DEBUG
    package extension AdaptyUI.Button {
        static func debugCreate(
            action: AdaptyUI.ButtonAction? = nil,
            isSelected: Bool = defaultIsSelected,
            normalState: AdaptyUI.Element? = nil,
            selectedState: AdaptyUI.Element? = nil
        ) -> Self {
            .init(
                action: action,
                isSelected: isSelected,
                normalState: normalState,
                selectedState: selectedState
            )
        }
    }
#endif
