//
//  Element.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUI {
    package enum Element: Sendable {
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
        indirect case pager(AdaptyUI.Pager, Properties?)

        case unknown(String, Properties?)
    }
}

extension AdaptyUI.Element {
    package struct Properties: Sendable, Hashable {
        static let defaultPadding = AdaptyUI.EdgeInsets(same: .point(0))
        static let defaultOffset = AdaptyUI.Offset.zero
        static let defaultVisibility = false

        package let decorator: AdaptyUI.Decorator?
        package let padding: AdaptyUI.EdgeInsets
        package let offset: AdaptyUI.Offset

        package let visibility: Bool
        package let transitionIn: [AdaptyUI.Transition]
    }
}

extension AdaptyUI.Element: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .space(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .stack(value, properties):
            hasher.combine(2)
            hasher.combine(value)
            hasher.combine(properties)
        case let .text(value, properties):
            hasher.combine(3)
            hasher.combine(value)
            hasher.combine(properties)
        case let .image(value, properties):
            hasher.combine(4)
            hasher.combine(value)
            hasher.combine(properties)
        case let .button(value, properties):
            hasher.combine(5)
            hasher.combine(value)
            hasher.combine(properties)
        case let .box(value, properties):
            hasher.combine(6)
            hasher.combine(value)
            hasher.combine(properties)
        case let .row(value, properties):
            hasher.combine(7)
            hasher.combine(value)
            hasher.combine(properties)
        case let .column(value, properties):
            hasher.combine(8)
            hasher.combine(value)
            hasher.combine(properties)
        case let .section(value, properties):
            hasher.combine(9)
            hasher.combine(value)
            hasher.combine(properties)
        case let .toggle(value, properties):
            hasher.combine(10)
            hasher.combine(value)
            hasher.combine(properties)
        case let .timer(value, properties):
            hasher.combine(11)
            hasher.combine(value)
            hasher.combine(properties)
        case let .pager(value, properties):
            hasher.combine(12)
            hasher.combine(value)
            hasher.combine(properties)
        case let .unknown(value, properties):
            hasher.combine(13)
            hasher.combine(value)
            hasher.combine(properties)
        }
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
