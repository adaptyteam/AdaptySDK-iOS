//
//  Element.swift
//  AdaptySDK
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

        var properties: Properties? {
            switch self {
            case .space: nil
            case let .stack(_, properties),
                 let .text(_, properties),
                 let .image(_, properties),
                 let .button(_, properties):
                properties
            }
        }
    }
}

extension AdaptyUI.Element {
    public struct Properties {
        static let zero = Properties(
            decorastor: nil,
            frsme: nil,
            padding: AdaptyUI.EdgeInsets.zero,
            offset: AdaptyUI.Offset.zero,
            visibility: true,
            transitionIn: []
        )
        public let decorastor: AdaptyUI.Decorator?
        public let frsme: AdaptyUI.Frame?
        public let padding: AdaptyUI.EdgeInsets
        public let offset: AdaptyUI.Offset

        public let visibility: Bool
        public let transitionIn: [AdaptyUI.Transition]
    }
}
