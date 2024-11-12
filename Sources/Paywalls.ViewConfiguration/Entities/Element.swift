//
//  Element.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension AdaptyUICore {
    package enum Element: Sendable {
        case space(Int)
        indirect case stack(AdaptyUICore.Stack, Properties?)
        case text(AdaptyUICore.Text, Properties?)
        case image(AdaptyUICore.Image, Properties?)
        case video(AdaptyUICore.VideoPlayer, Properties?)
        indirect case button(AdaptyUICore.Button, Properties?)
        indirect case box(AdaptyUICore.Box, Properties?)
        indirect case row(AdaptyUICore.Row, Properties?)
        indirect case column(AdaptyUICore.Column, Properties?)
        indirect case section(AdaptyUICore.Section, Properties?)
        case toggle(AdaptyUICore.Toggle, Properties?)
        case timer(AdaptyUICore.Timer, Properties?)
        indirect case pager(AdaptyUICore.Pager, Properties?)

        case unknown(String, Properties?)
    }
}

extension AdaptyUICore.Element {
    package struct Properties: Sendable, Hashable {
        static let defaultPadding = AdaptyUICore.EdgeInsets(same: .point(0))
        static let defaultOffset = AdaptyUICore.Offset.zero
        static let defaultVisibility = false

        package let decorator: AdaptyUICore.Decorator?
        package let padding: AdaptyUICore.EdgeInsets
        package let offset: AdaptyUICore.Offset

        package let visibility: Bool
        package let transitionIn: [AdaptyUICore.Transition]
    }
}

extension AdaptyUICore.Element: Hashable {
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
        case let .video(value, properties):
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
    package extension AdaptyUICore.Element.Properties {
        static func create(
            decorator: AdaptyUICore.Decorator? = nil,
            padding: AdaptyUICore.EdgeInsets = AdaptyUICore.Element.Properties.defaultPadding,
            offset: AdaptyUICore.Offset = AdaptyUICore.Element.Properties.defaultOffset,
            visibility: Bool = AdaptyUICore.Element.Properties.defaultVisibility,
            transitionIn: [AdaptyUICore.Transition] = []
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
