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

        public let normal: State?
        public let selected: State?

        public let align: Align
        public let action: ButtonAction?

        public let visibility: Bool
        public let transitionIn: [AdaptyUI.Transition]
    }
}

extension AdaptyUI.Button {
    public struct State {
        public let shape: AdaptyUI.Shape?
        public let title: AdaptyUI.CompoundText?

        var isEmpty: Bool {
            (shape == nil) && (title?.isEmpty ?? true)
        }
    }

    public enum Align: String {
        case leading
        case trailing
        case center
        case fill
    }
}
