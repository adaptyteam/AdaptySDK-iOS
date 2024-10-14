//
//  VC.Element.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    enum Element: Sendable {
        case reference(String)
        indirect case stack(AdaptyUI.ViewConfiguration.Stack, Properties?)
        case text(AdaptyUI.ViewConfiguration.Text, Properties?)
        case image(AdaptyUI.ViewConfiguration.Image, Properties?)
        case video(AdaptyUI.ViewConfiguration.VideoPlayer, Properties?)
        indirect case button(AdaptyUI.ViewConfiguration.Button, Properties?)
        indirect case box(AdaptyUI.ViewConfiguration.Box, Properties?)
        indirect case row(AdaptyUI.ViewConfiguration.Row, Properties?)
        indirect case column(AdaptyUI.ViewConfiguration.Column, Properties?)
        indirect case section(AdaptyUI.ViewConfiguration.Section, Properties?)
        case toggle(AdaptyUI.ViewConfiguration.Toggle, Properties?)
        case timer(AdaptyUI.ViewConfiguration.Timer, Properties?)
        indirect case pager(AdaptyUI.ViewConfiguration.Pager, Properties?)

        case unknown(String, Properties?)
    }
}

extension AdaptyUI.ViewConfiguration.Element {
    struct Properties: Sendable, Hashable {
        let elementId: String?
        let decorator: AdaptyUI.ViewConfiguration.Decorator?
        let padding: AdaptyUI.EdgeInsets
        let offset: AdaptyUI.Offset

        let visibility: Bool
        let transitionIn: [AdaptyUI.Transition]

        var isZero: Bool {
            elementId == nil
                && decorator == nil
                && padding.isZero
                && offset.isZero
                && visibility
                && transitionIn.isEmpty
        }
    }
}

extension AdaptyUI.ViewConfiguration.Element: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .reference(value):
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

extension AdaptyUI.ViewConfiguration.Localizer {
    func element(_ from: AdaptyUI.ViewConfiguration.Element) throws -> AdaptyUI.Element {
        switch from {
        case let .reference(id):
            try reference(id)
        case let .stack(value, properties):
            try .stack(stack(value), properties.flatMap(elementProperties))
        case let .text(value, properties):
            try .text(text(value), properties.flatMap(elementProperties))
        case let .image(value, properties):
            try .image(image(value), properties.flatMap(elementProperties))
        case let .video(value, properties):
            try .video(videoPlayer(value), properties.flatMap(elementProperties))
        case let .button(value, properties):
            try .button(button(value), properties.flatMap(elementProperties))
        case let .box(value, properties):
            try .box(box(value), properties.flatMap(elementProperties))
        case let .row(value, properties):
            try .row(row(value), properties.flatMap(elementProperties))
        case let .column(value, properties):
            try .column(column(value), properties.flatMap(elementProperties))
        case let .section(value, properties):
            try .section(section(value), properties.flatMap(elementProperties))
        case let .toggle(value, properties):
            try .toggle(toggle(value), properties.flatMap(elementProperties))
        case let .timer(value, properties):
            try .timer(timer(value), properties.flatMap(elementProperties))
        case let .pager(value, properties):
            try .pager(pager(value), properties.flatMap(elementProperties))
        case let .unknown(value, properties):
            try .unknown(value, properties.flatMap(elementProperties))
        }
    }

    private func elementProperties(_ from: AdaptyUI.ViewConfiguration.Element.Properties) throws -> AdaptyUI.Element.Properties? {
        guard !from.isZero else { return nil }
        return try .init(
            decorator: from.decorator.map(decorator),
            padding: from.padding,
            offset: from.offset,
            visibility: from.visibility,
            transitionIn: from.transitionIn
        )
    }
}

extension AdaptyUI.ViewConfiguration.Element: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case count
        case elementId = "element_id"
    }

    enum ContentType: String, Codable {
        case text
        case image
        case video
        case button
        case box
        case vStack = "v_stack"
        case hStack = "h_stack"
        case zStack = "z_stack"
        case row
        case column
        case section
        case toggle
        case timer
        case `if`
        case reference
        case pager
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        guard let contentType = ContentType(rawValue: type) else {
            self = .unknown(type, propertyOrNil())
            return
        }

        switch contentType {
        case .if:
            self = try AdaptyUI.ViewConfiguration.If(from: decoder).content
        case .reference:
            self = try .reference(container.decode(String.self, forKey: .elementId))
        case .box:
            self = try .box(AdaptyUI.ViewConfiguration.Box(from: decoder), propertyOrNil())
        case .vStack, .hStack, .zStack:
            self = try .stack(AdaptyUI.ViewConfiguration.Stack(from: decoder), propertyOrNil())
        case .button:
            self = try .button(AdaptyUI.ViewConfiguration.Button(from: decoder), propertyOrNil())
        case .text:
            self = try .text(AdaptyUI.ViewConfiguration.Text(from: decoder), propertyOrNil())
        case .image:
            self = try .image(AdaptyUI.ViewConfiguration.Image(from: decoder), propertyOrNil())
        case .video:
            self = try .video(AdaptyUI.ViewConfiguration.VideoPlayer(from: decoder), propertyOrNil())
        case .row:
            self = try .row(AdaptyUI.ViewConfiguration.Row(from: decoder), propertyOrNil())
        case .column:
            self = try .column(AdaptyUI.ViewConfiguration.Column(from: decoder), propertyOrNil())
        case .section:
            self = try .section(AdaptyUI.ViewConfiguration.Section(from: decoder), propertyOrNil())
        case .toggle:
            self = try .toggle(AdaptyUI.ViewConfiguration.Toggle(from: decoder), propertyOrNil())
        case .timer:
            self = try .timer(AdaptyUI.ViewConfiguration.Timer(from: decoder), propertyOrNil())
        case .pager:
            self = try .pager(AdaptyUI.ViewConfiguration.Pager(from: decoder), propertyOrNil())
        }

        func propertyOrNil() -> Properties? {
            guard let value = try? Properties(from: decoder) else { return nil }
            return value.isZero ? nil : value
        }
    }
}

extension AdaptyUI.ViewConfiguration.Element.Properties: Decodable {
    enum CodingKeys: String, CodingKey {
        case elementId = "element_id"
        case decorator
        case padding
        case offset
        case visibility
        case transitionIn = "transition_in"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let transitionIn: [AdaptyUI.Transition] =
            if let array = try? container.decodeIfPresent([AdaptyUI.Transition].self, forKey: .transitionIn) {
                array
            } else if let transition = try container.decodeIfPresent(AdaptyUI.Transition.self, forKey: .transitionIn) {
                [transition]
            } else {
                []
            }
        try self.init(
            elementId: container.decodeIfPresent(String.self, forKey: .elementId),
            decorator: container.decodeIfPresent(AdaptyUI.ViewConfiguration.Decorator.self, forKey: .decorator),
            padding: container.decodeIfPresent(AdaptyUI.EdgeInsets.self, forKey: .padding) ?? AdaptyUI.Element.Properties.defaultPadding,
            offset: container.decodeIfPresent(AdaptyUI.Offset.self, forKey: .offset) ?? AdaptyUI.Element.Properties.defaultOffset,
            visibility: container.decodeIfPresent(Bool.self, forKey: .visibility) ?? AdaptyUI.Element.Properties.defaultVisibility,
            transitionIn: transitionIn
        )
    }
}
