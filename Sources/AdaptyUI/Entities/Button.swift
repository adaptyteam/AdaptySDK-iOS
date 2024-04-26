//
//  Button.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Button {
        package let action: ButtonAction?
        package let isSelected: Bool
        package let normalState: AdaptyUI.Element?
        package let selectedState: AdaptyUI.Element?
    }
}
