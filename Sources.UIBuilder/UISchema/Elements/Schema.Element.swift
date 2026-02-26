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
        indirect case templateInstance(Schema.TemplateInstance)
        case scrrenHolder
        indirect case stack(Schema.Stack, Properties?)
        indirect case text(Schema.Text, Properties?)
        indirect case textField(Schema.TextField, Properties?)
        indirect case image(Schema.Image, Properties?)
        indirect case video(Schema.VideoPlayer, Properties?)
        indirect case button(Schema.Button, Properties?)
        indirect case box(Schema.Box, Properties?)
        indirect case row(Schema.Row, Properties?)
        indirect case column(Schema.Column, Properties?)
        indirect case section(Schema.Section, Properties?)
        indirect case toggle(Schema.Toggle, Properties?)
        indirect case slider(Schema.Slider, Properties?)
        indirect case timer(Schema.Timer, Properties?)
        indirect case pager(Schema.Pager, Properties?)

        indirect case unknown(String, Properties?)
    }
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func planElement(
        _ from: Schema.Element,
        in taskStack: inout [Task]
    ) throws(Schema.Error) -> VC.Element? {
        switch from {
        case let .legacyReference(id):
            try planLegacyReference(id, in: &taskStack)
        case let .templateInstance(value):
            try planTemplateInstance(value, in: &taskStack)
        case .scrrenHolder:
            return .screenHolder
        case let .stack(value, properties):
            planStack(value, properties?.value, in: &taskStack)
        case let .text(value, properties):
            return .text(value, properties?.value)
        case let .textField(value, properties):
            return .textField(value, properties?.value)
        case let .image(value, properties):
            return .image(value, properties?.value)
        case let .video(value, properties):
            return .video(value, properties?.value)
        case let .button(value, properties):
            planButton(value, properties?.value, in: &taskStack)
        case let .box(value, properties):
            planBox(value, properties?.value, in: &taskStack)
        case let .row(value, properties):
            planRow(value, properties?.value, in: &taskStack)
        case let .column(value, properties):
            planColumn(value, properties?.value, in: &taskStack)
        case let .section(value, properties):
            planSection(value, properties?.value, in: &taskStack)
        case let .toggle(value, properties):
            return .toggle(value, properties?.value)
        case let .slider(value, properties):
            return .slider(value, properties?.value)
        case let .timer(value, properties):
            return .timer(convertTimer(value), properties?.value)
        case let .pager(value, properties):
            planPager(value, properties?.value, in: &taskStack)
        case let .unknown(value, properties):
            return .unknown(value, properties?.value)
        }
        return nil
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
            if configuration.isLegacy, type.hasPrefix(Schema.Template.keyPrefix) {
                self = .unknown(type, propertyOrNil())
            } else {
                self = try .templateInstance(Schema.TemplateInstance(from: decoder, configuration: configuration))
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
            self = try .toggle(Schema.Toggle(from: decoder, configuration: configuration), propertyOrNil())
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
