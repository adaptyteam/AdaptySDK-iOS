//
//  FooterBlock.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUI {
    public enum FooterBlock {
        public struct Button {
            public let id: String
            public let action: ButtonAction
        }

        public enum ButtonAction {
            case openUrl(String?)
            case restore
            case custom
        }
    }
}
