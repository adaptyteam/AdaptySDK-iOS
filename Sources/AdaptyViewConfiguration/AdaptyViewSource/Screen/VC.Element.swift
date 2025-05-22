//
//  VC.Element.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyViewSource {
    enum Element: Sendable {
        case reference(String)
        indirect case stack(AdaptyViewSource.Stack, Properties?)
        case text(AdaptyViewSource.Text, Properties?)
        case image(AdaptyViewSource.Image, Properties?)
        case video(AdaptyViewSource.VideoPlayer, Properties?)
        indirect case button(AdaptyViewSource.Button, Properties?)
        indirect case box(AdaptyViewSource.Box, Properties?)
        indirect case row(AdaptyViewSource.Row, Properties?)
        indirect case column(AdaptyViewSource.Column, Properties?)
        indirect case section(AdaptyViewSource.Section, Properties?)
        case toggle(AdaptyViewSource.Toggle, Properties?)
        case timer(AdaptyViewSource.Timer, Properties?)
        indirect case pager(AdaptyViewSource.Pager, Properties?)

        case unknown(String, Properties?)
    }
}

extension AdaptyViewSource.Element {
    struct Properties: Sendable, Hashable {
        let elementId: String?
        let decorator: AdaptyViewSource.Decorator?
        let padding: AdaptyViewConfiguration.EdgeInsets
        let offset: AdaptyViewConfiguration.Offset

        let visibility: Bool
        let transitionIn: [AdaptyViewConfiguration.Transition]

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

extension AdaptyViewSource.Element: Hashable {
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

extension AdaptyViewSource.Localizer {
    func element(_ from: AdaptyViewSource.Element) throws -> AdaptyViewConfiguration.Element {
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

    private func elementProperties(_ from: AdaptyViewSource.Element.Properties) throws -> AdaptyViewConfiguration.Element.Properties? {
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

extension AdaptyViewSource.Element: Codable {
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
            self = try AdaptyViewSource.If(from: decoder).content
        case .reference:
            self = try .reference(container.decode(String.self, forKey: .elementId))
        case .box:
            self = try .box(AdaptyViewSource.Box(from: decoder), propertyOrNil())
        case .vStack, .hStack, .zStack:
            self = try .stack(AdaptyViewSource.Stack(from: decoder), propertyOrNil())
        case .button:
            self = try .button(AdaptyViewSource.Button(from: decoder), propertyOrNil())
        case .text:
            self = try .text(AdaptyViewSource.Text(from: decoder), propertyOrNil())
        case .image:
            self = try .image(AdaptyViewSource.Image(from: decoder), propertyOrNil())
        case .video:
            self = try .video(AdaptyViewSource.VideoPlayer(from: decoder), propertyOrNil())
        case .row:
            self = try .row(AdaptyViewSource.Row(from: decoder), propertyOrNil())
        case .column:
            self = try .column(AdaptyViewSource.Column(from: decoder), propertyOrNil())
        case .section:
            self = try .section(AdaptyViewSource.Section(from: decoder), propertyOrNil())
        case .toggle:
            self = try .toggle(AdaptyViewSource.Toggle(from: decoder), propertyOrNil())
        case .timer:
            self = try .timer(AdaptyViewSource.Timer(from: decoder), propertyOrNil())
        case .pager:
            self = try .pager(AdaptyViewSource.Pager(from: decoder), propertyOrNil())
        }

        func propertyOrNil() -> Properties? {
            guard let value = try? Properties(from: decoder) else { return nil }
            return value.isZero ? nil : value
        }
    }

    func encode(to encoder: any Encoder) throws {
        // TODO: implement
    }
}

extension AdaptyViewSource.Element.Properties: Decodable {
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
        let transitionIn: [AdaptyViewConfiguration.Transition] =
            if let array = try? container.decodeIfPresent([AdaptyViewConfiguration.Transition].self, forKey: .transitionIn) {
                array
            } else if let transition = try container.decodeIfPresent(AdaptyViewConfiguration.Transition.self, forKey: .transitionIn) {
                [transition]
            } else {
                []
            }
        try self.init(
            elementId: container.decodeIfPresent(String.self, forKey: .elementId),
            decorator: container.decodeIfPresent(AdaptyViewSource.Decorator.self, forKey: .decorator),
            padding: container.decodeIfPresent(AdaptyViewConfiguration.EdgeInsets.self, forKey: .padding) ?? AdaptyViewConfiguration.Element.Properties.defaultPadding,
            offset: container.decodeIfPresent(AdaptyViewConfiguration.Offset.self, forKey: .offset) ?? AdaptyViewConfiguration.Element.Properties.defaultOffset,
            visibility: container.decodeIfPresent(Bool.self, forKey: .visibility) ?? AdaptyViewConfiguration.Element.Properties.defaultVisibility,
            transitionIn: transitionIn
        )
    }
}
