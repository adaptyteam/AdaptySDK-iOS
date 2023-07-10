//
//  Button.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.06.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct Button {
        static let defaultAlign = Align.center

        public let shape: Shape?
        public let highlighted: Shape?

        public let title: TextItems?
        public let align: Align
        public let action: ButtonAction?
    }
}

extension AdaptyUI.Button {
    public enum Align: String {
        case leading
        case trailing
        case center
        case fill
    }
}
