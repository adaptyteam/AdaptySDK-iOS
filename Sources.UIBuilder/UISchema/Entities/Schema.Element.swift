//
//  Schema.Element.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    enum Element: Sendable {
        case reference(String)
        indirect case stack(Schema.Stack, Properties?)
        case text(Schema.Text, Properties?)
        case image(Schema.Image, Properties?)
        case video(Schema.VideoPlayer, Properties?)
        indirect case button(Schema.Button, Properties?)
        indirect case box(Schema.Box, Properties?)
        indirect case row(Schema.Row, Properties?)
        indirect case column(Schema.Column, Properties?)
        indirect case section(Schema.Section, Properties?)
        case toggle(Schema.Toggle, Properties?)
        case timer(Schema.Timer, Properties?)
        indirect case pager(Schema.Pager, Properties?)

        case unknown(String, Properties?)
    }
}

extension Schema.Element {
    struct Properties: Sendable {
        let elementId: String?
        let decorator: Schema.Decorator?
        let padding: AdaptyUIConfiguration.EdgeInsets
        let offset: AdaptyUIConfiguration.Offset

        let opacity: Double
        let onAppear: [Schema.Animation]

        var isZero: Bool {
            elementId == nil
                && decorator == nil
                && padding.isZero
                && offset.isZero
                && opacity == 0
                && onAppear.isEmpty
        }
    }
}

extension Schema.Localizer {
    func element(_ from: Schema.Element) throws -> AdaptyUIConfiguration.Element {
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

    private func elementProperties(_ from: Schema.Element.Properties) throws -> AdaptyUIConfiguration.Element.Properties? {
        guard !from.isZero else { return nil }
        return try .init(
            decorator: from.decorator.map(decorator),
            padding: from.padding,
            offset: from.offset,
            opacity: from.opacity,
            onAppear: from.onAppear.map(animation)
        )
    }
}

extension Schema.Element: Codable {
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
            self = try Schema.If(from: decoder).content
        case .reference:
            self = try .reference(container.decode(String.self, forKey: .elementId))
        case .box:
            self = try .box(Schema.Box(from: decoder), propertyOrNil())
        case .vStack, .hStack, .zStack:
            self = try .stack(Schema.Stack(from: decoder), propertyOrNil())
        case .button:
            self = try .button(Schema.Button(from: decoder), propertyOrNil())
        case .text:
            self = try .text(Schema.Text(from: decoder), propertyOrNil())
        case .image:
            self = try .image(Schema.Image(from: decoder), propertyOrNil())
        case .video:
            self = try .video(Schema.VideoPlayer(from: decoder), propertyOrNil())
        case .row:
            self = try .row(Schema.Row(from: decoder), propertyOrNil())
        case .column:
            self = try .column(Schema.Column(from: decoder), propertyOrNil())
        case .section:
            self = try .section(Schema.Section(from: decoder), propertyOrNil())
        case .toggle:
            self = try .toggle(Schema.Toggle(from: decoder), propertyOrNil())
        case .timer:
            self = try .timer(Schema.Timer(from: decoder), propertyOrNil())
        case .pager:
            self = try .pager(Schema.Pager(from: decoder), propertyOrNil())
        }

        func propertyOrNil() -> Properties? {
            guard let value = try? Properties(from: decoder) else { return nil }
            return value.isZero ? nil : value
        }
    }

    func encode(to _: any Encoder) throws {
        // TODO: implement
    }
}

extension Schema.Element.Properties: Decodable {
    enum CodingKeys: String, CodingKey {
        case elementId = "element_id"
        case decorator
        case padding
        case offset
        case visibility
        case opacity
        case transitionIn = "transition_in"
        case onAppear = "on_appear"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let onAppear: [Schema.Animation] =
            if container.contains(.transitionIn) && !container.contains(.onAppear) {
                if let animation = try container.decodeIfPresent(Schema.Animation.self, forKey: .transitionIn) { [animation] } else { [] }
            } else {
                if let array = try? container.decodeIfPresent([Schema.Animation].self, forKey: .onAppear) {
                    array
                } else { [] }
            }

        let opacity = if container.contains(.visibility) && !container.contains(.opacity) {
            try container.decodeIfPresent(Bool.self, forKey: .visibility) ?? true ? 1.0 : 0.0
        } else {
            try container.decodeIfPresent(Double.self, forKey: .opacity) ?? AdaptyUIConfiguration.Element.Properties.defaultOpacity
        }

        try self.init(
            elementId: container.decodeIfPresent(String.self, forKey: .elementId),
            decorator: container.decodeIfPresent(Schema.Decorator.self, forKey: .decorator),
            padding: container.decodeIfPresent(AdaptyUIConfiguration.EdgeInsets.self, forKey: .padding) ?? AdaptyUIConfiguration.Element.Properties.defaultPadding,
            offset: container.decodeIfPresent(AdaptyUIConfiguration.Offset.self, forKey: .offset) ?? AdaptyUIConfiguration.Element.Properties.defaultOffset,
            opacity: opacity,
            onAppear: onAppear
        )
    }
}
