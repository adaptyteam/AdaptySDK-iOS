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
        indirect case row(AdaptyUI.Row, Properties?)
        indirect case column(AdaptyUI.Column, Properties?)
        indirect case section(AdaptyUI.Section, Properties?)
        case toggle(AdaptyUI.Toggle, Properties?)
        case timer(AdaptyUI.Timer, Properties?)

        case unknown(String, Properties?)

//        var properties: Properties? {
//            switch self {
//            case .space: nil
//            case let .stack(_, properties),
//                 let .text(_, properties),
//                 let .image(_, properties),
//                 let .button(_, properties),
//                 let .toggle(_, properties),
//                 let .box(_, properties),
//                 let .row(_, properties),
//                 let .column(_, properties),
//                 let .section(_, properties),
//                 let .timer(_, properties),
//                 let .unknown(_, properties):
//                properties
//            }
//        }
    }
}

extension AdaptyUI.Element {
    package struct Properties {
        static let defaultPadding = AdaptyUI.EdgeInsets(same: 0)
        static let defaultOffset = AdaptyUI.Offset.zero
        static let defaultVisibility = false

        package let decorator: AdaptyUI.Decorator?
        package let padding: AdaptyUI.EdgeInsets
        package let offset: AdaptyUI.Offset

        package let visibility: Bool
        package let transitionIn: [AdaptyUI.Transition]
    }
}

#if DEBUG
    package extension AdaptyUI.Element.Properties {
        static func create(
            decorator: AdaptyUI.Decorator? = nil,
            padding: AdaptyUI.EdgeInsets = AdaptyUI.Element.Properties.defaultPadding,
            offset: AdaptyUI.Offset = AdaptyUI.Element.Properties.defaultOffset,
            visibility: Bool = AdaptyUI.Element.Properties.defaultVisibility,
            transitionIn: [AdaptyUI.Transition] = []
        ) -> Self {
            .init(
                decorator: decorator,
                padding: padding,
                offset: offset,
                visibility: visibility,
                transitionIn: transitionIn
            )
        }
    }
#endif
