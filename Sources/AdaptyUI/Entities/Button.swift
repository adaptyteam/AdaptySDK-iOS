//
//  Button.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    public struct Button {
        public let action: ButtonAction?
        public let isSelected: Bool
        public let normalState: AdaptyUI.Element?
        public let selectedState: AdaptyUI.Element?
    }
}
