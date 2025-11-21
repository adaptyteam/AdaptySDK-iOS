//
//  VC.Element.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension VC {
    enum Element: Sendable {
        case space(Int)
        indirect case stack(VC.Stack, Properties?)
        case text(VC.Text, Properties?)
        case image(VC.Image, Properties?)
        case video(VC.VideoPlayer, Properties?)
        indirect case button(VC.Button, Properties?)
        indirect case box(VC.Box, Properties?)
        indirect case row(VC.Row, Properties?)
        indirect case column(VC.Column, Properties?)
        indirect case section(VC.Section, Properties?)
        case toggle(VC.Toggle, Properties?)
        case timer(VC.Timer, Properties?)
        indirect case pager(VC.Pager, Properties?)

        case unknown(String, Properties?)
    }
}

package extension VC.Element {
    struct Properties: Sendable, Hashable {
        static let defaultPadding = VC.EdgeInsets(same: .point(0))
        static let defaultOffset = VC.Offset.zero
        static let defaultOpacity: Double = 1

        package let decorator: VC.Decorator?
        package let padding: VC.EdgeInsets
        package let offset: VC.Offset

        package let opacity: Double
        package let onAppear: [VC.Animation]
    }
}

extension VC.Element: Hashable {
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
package extension VC.Element.Properties {
    static func create(
        decorator: VC.Decorator? = nil,
        padding: VC.EdgeInsets = VC.Element.Properties.defaultPadding,
        offset: VC.Offset = VC.Element.Properties.defaultOffset,
        opacity: Double = VC.Element.Properties.defaultOpacity,
        onAppear: [VC.Animation] = []
    ) -> Self {
        .init(
            decorator: decorator,
            padding: padding,
            offset: offset,
            opacity: opacity,
            onAppear: onAppear
        )
    }
}
#endif
