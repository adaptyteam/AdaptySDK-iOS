//
//  Element.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    public enum Element {
        case space(Int)
        indirect case stack(AdaptyUI.Stack, Properties?)
        case text(AdaptyUI.RichText, Properties?)
        case image(AdaptyUI.Image, Properties?)
        indirect case button(AdaptyUI.Button, Properties?)
        case unknown(String, Properties?)

        var properties: Properties? {
            switch self {
            case .space: nil
            case let .stack(_, properties),
                 let .text(_, properties),
                 let .image(_, properties),
                 let .button(_, properties),
                 let .unknown(_, properties):
                properties
            }
        }
    }
}

extension AdaptyUI.Element {
    public struct Properties {
        public let decorator: AdaptyUI.Decorator?
        public let frame: AdaptyUI.Frame?
        public let padding: AdaptyUI.EdgeInsets
        public let offset: AdaptyUI.Offset

        public let visibility: Bool
        public let transitionIn: [AdaptyUI.Transition]
    }
}
