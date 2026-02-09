//
//  Schema.Element.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    enum Element: Sendable, Hashable {
        case legacyReference(String)
        case templateInstance(Schema.TemplateInstance, Properties?)
        case scrrenHolder
        indirect case stack(Schema.Stack, Properties?)
        case text(Schema.Text, Properties?)
        case textField(Schema.TextField, Properties?)
        case image(Schema.Image, Properties?)
        case video(Schema.VideoPlayer, Properties?)
        indirect case button(Schema.Button, Properties?)
        indirect case box(Schema.Box, Properties?)
        indirect case row(Schema.Row, Properties?)
        indirect case column(Schema.Column, Properties?)
        indirect case section(Schema.Section, Properties?)
        case toggle(Schema.Toggle, Properties?)
        case slider(Schema.Slider, Properties?)
        case timer(Schema.Timer, Properties?)
        indirect case pager(Schema.Pager, Properties?)

        case unknown(String, Properties?)
    }
}

extension Schema.Localizer {
    func element(_ from: Schema.Element) throws -> VC.Element {
        switch from {
        case let .legacyReference(id):
            try legacyReference(id)
        case let .templateInstance(instance, properties):
            try templateInstance(instance, properties: properties?.value)
        case .scrrenHolder:
            .screenHolder
        case let .stack(value, properties):
            try .stack(stack(value), properties?.value)
        case let .text(value, properties):
            .text(value, properties?.value)
        case let .textField(value, properties):
            .textField(value, properties?.value)
        case let .image(value, properties):
            .image(value, properties?.value)
        case let .video(value, properties):
            .video(value, properties?.value)
        case let .button(value, properties):
            try .button(button(value), properties?.value)
        case let .box(value, properties):
            try .box(box(value), properties?.value)
        case let .row(value, properties):
            try .row(row(value), properties?.value)
        case let .column(value, properties):
            try .column(column(value), properties?.value)
        case let .section(value, properties):
            try .section(section(value), properties?.value)
        case let .toggle(value, properties):
            .toggle(value, properties?.value)
        case let .slider(value, properties):
            .slider(value, properties?.value)
        case let .timer(value, properties):
            .timer(timer(value), properties?.value)
        case let .pager(value, properties):
            try .pager(pager(value), properties?.value)
        case let .unknown(value, properties):
            .unknown(value, properties?.value)
        }
    }
}

extension Schema.Element: Encodable, DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case type
        case count
        case legacyElementId = "element_id"
    }

    enum ContentType: String, Codable {
        case text
        case textField = "text_field"
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
        case slider
        case timer
        case `if`
        case legacyReference
        case pager
        case screenHolder = "screen_holder"
    }

    init(from decoder: any Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        guard let contentType = ContentType(rawValue: type) else {
            if !configuration.isLegacy, type.hasPrefix(Schema.Template.keyPrefix) {
                self = try .templateInstance(
                    Schema.TemplateInstance(from: decoder, configuration: configuration),
                    propertyOrNil()
                )
            } else {
                self = .unknown(type, propertyOrNil())
            }
            return
        }

        switch contentType {
        case .if:
            self = try Schema.If(from: decoder, configuration: configuration).content
        case .legacyReference:
            if configuration.isLegacy {
                self = try .legacyReference(container.decode(String.self, forKey: .legacyElementId))
            } else {
                throw Schema.Error.unsupportedElement(type)
            }
        case .screenHolder:
            if configuration.isNavigator {
                self = .scrrenHolder
            } else {
                throw Schema.Error.unsupportedElement(type)
            }
        case .box:
            self = try .box(Schema.Box(from: decoder, configuration: configuration), propertyOrNil())
        case .vStack, .hStack, .zStack:
            self = try .stack(Schema.Stack(from: decoder, configuration: configuration), propertyOrNil())
        case .button:
            self = try .button(Schema.Button(from: decoder, configuration: configuration), propertyOrNil())
        case .text:
            self = try .text(Schema.Text(from: decoder), propertyOrNil())
        case .textField:
            self = try .textField(Schema.TextField(from: decoder), propertyOrNil())
        case .image:
            self = try .image(Schema.Image(from: decoder), propertyOrNil())
        case .video:
            self = try .video(Schema.VideoPlayer(from: decoder), propertyOrNil())
        case .row:
            self = try .row(Schema.Row(from: decoder, configuration: configuration), propertyOrNil())
        case .column:
            self = try .column(Schema.Column(from: decoder, configuration: configuration), propertyOrNil())
        case .section:
            self = try .section(Schema.Section(from: decoder, configuration: configuration), propertyOrNil())
        case .toggle:
            self = try .toggle(Schema.Toggle(from: decoder), propertyOrNil())
        case .slider:
            self = try .slider(Schema.Slider(from: decoder), propertyOrNil())
        case .timer:
            self = try .timer(Schema.Timer(from: decoder), propertyOrNil())
        case .pager:
            self = try .pager(Schema.Pager(from: decoder, configuration: configuration), propertyOrNil())
        }

        func propertyOrNil() -> Properties? {
            guard let properties = try? Properties(from: decoder) else { return nil }
            return (properties.legacyElementId == nil && properties.value == nil) ? nil : properties
        }
    }

    func encode(to encoder: any Encoder) throws {
        // TODO: implement
    }
}
