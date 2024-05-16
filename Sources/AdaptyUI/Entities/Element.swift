//
//  Element.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    package enum Element {
        case space(Int)
        indirect case stack(AdaptyUI.Stack, Properties?)
        case text(AdaptyUI.Text, Properties?)
        case image(AdaptyUI.Image, Properties?)
        indirect case button(AdaptyUI.Button, Properties?)
        indirect case box(AdaptyUI.Box, Properties?)
        case unknown(String, Properties?)

        var properties: Properties? {
            switch self {
            case .space: nil
            case let .stack(_, properties),
                 let .text(_, properties),
                 let .image(_, properties),
                 let .button(_, properties),
                 let .box(_, properties),
                 let .unknown(_, properties):
                properties
            }
        }
    }
}

extension AdaptyUI.Element {
    package struct Properties {
        package let decorator: AdaptyUI.Decorator?
        package let padding: AdaptyUI.EdgeInsets
        package let offset: AdaptyUI.Offset

        package let visibility: Bool
        package let transitionIn: [AdaptyUI.Transition]
    }
}
