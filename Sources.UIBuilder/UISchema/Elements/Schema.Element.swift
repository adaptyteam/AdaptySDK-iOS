//
//  Schema.Element.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    protocol SimpleElement: Sendable {
        func buildElement(
            _: Schema.ConfigurationBuilder,
            _: VC.Element.Properties?
        ) -> VC.Element
    }

    protocol CompositeElement: Sendable {
        func planTasks(in: inout Schema.ConfigurationBuilder.TasksStack)
        func buildElement(
            _: Schema.ConfigurationBuilder,
            _: VC.Element.Properties?,
            _: inout Schema.ConfigurationBuilder.ResultStack
        ) throws(Schema.Error) -> VC.Element
    }

    struct Element: Sendable {
        let properties: ElementProperties?
        let node: Node
    }

    enum Node: Sendable {
        case legacyReference(String)
        indirect case templateInstance(Schema.TemplateInstance)
        case screenHolder
        case simpleElement(any SimpleElement)
        case compositeElement(any CompositeElement)
        case unknown(String)
    }
}

extension Schema.Element {
    static let screenHolder: Self = .init(properties: nil, node: .screenHolder)
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func planElement(
        _ from: Schema.Element,
        in taskStack: inout TasksStack
    ) throws(Schema.Error) {
        switch from.node {
        case let .legacyReference(id):
            try planLegacyReference(id, in: &taskStack)
        case let .templateInstance(value):
            try planTemplateInstance(value, in: &taskStack)
        case .screenHolder:
            taskStack.append(.buildElement(from))
        case .unknown, .simpleElement:
            taskStack.append(.buildElement(from))
            planElementProperties(from.properties, in: &taskStack)
        case let .compositeElement(element):
            taskStack.append(.buildElement(from))
            planElementProperties(from.properties, in: &taskStack)
            element.planTasks(in: &taskStack)
        }
    }

    @inlinable
    func buildElement(
        _ from: Schema.Element,
        _ resultStack: inout ResultStack
    ) throws(Schema.Error) -> VC.Element? {
        switch from.node {
        case .legacyReference,
             .templateInstance:
            nil
        case .screenHolder:
            .screenHolder
        case let .unknown(unknown):
            .unknown(unknown)
        case let .simpleElement(simple):
            try simple.buildElement(
                self,
                buildElementProperties(from.properties, &resultStack)
            )
        case let .compositeElement(composite):
            try composite.buildElement(
                self,
                buildElementProperties(from.properties, &resultStack),
                &resultStack
            )
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
        case textEditor = "text_editor"
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
        case legacyReference = "reference"
        case pager
        case screenHolder = "screen_holder"
        case compactDateTimePicker = "compact_datetime_picker"
        case wheelDateTimePicker = "wheel_datetime_picker"
        case graphicalDateTimePicker = "graphical_datetime_picker"
        case wheelItemsPicker = "wheel_items_picker"
        case wheelRangePicker = "wheel_range_picker"
    }

    init(from decoder: any Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        guard let contentType = ContentType(rawValue: type) else {
            if configuration.isLegacy, type.hasPrefix(Schema.Template.keyPrefix) {
                self.init(
                    properties: propertyOrNil(),
                    node: .unknown(type)
                )
            } else {
                try self.init(
                    properties: propertyOrNil(),
                    node: .templateInstance(Schema.TemplateInstance(from: decoder, configuration: configuration))
                )
            }
            return
        }

        switch contentType {
        case .if:
            self = try Schema.If(from: decoder, configuration: configuration).content
        case .legacyReference:
            if configuration.isLegacy {
                try self.init(
                    properties: nil,
                    node: .legacyReference(container.decode(String.self, forKey: .legacyElementId))
                )
            } else {
                throw Schema.Error.unsupportedElement(type)
            }
        case .screenHolder:
            if configuration.isNavigator {
                self = .screenHolder
            } else {
                throw Schema.Error.unsupportedElement(type)
            }
        case .box:
            try self.init(
                properties: propertyOrNil(),
                node: .compositeElement(Schema.Box(from: decoder, configuration: configuration))
            )
        case .vStack, .hStack, .zStack:
            try self.init(
                properties: propertyOrNil(),
                node: .compositeElement(Schema.Stack(from: decoder, configuration: configuration))
            )
        case .button:
            try self.init(
                properties: propertyOrNil(),
                node: .compositeElement(Schema.Button(from: decoder, configuration: configuration))
            )
        case .text:
            try self.init(
                properties: propertyOrNil(),
                node: .simpleElement(Schema.Text(from: decoder))
            )
        case .textField, .textEditor:
            try self.init(
                properties: propertyOrNil(),
                node: .simpleElement(Schema.TextField(from: decoder))
            )
        case .image:
            try self.init(
                properties: propertyOrNil(),
                node: .simpleElement(Schema.Image(from: decoder))
            )
        case .video:
            try self.init(
                properties: propertyOrNil(),
                node: .simpleElement(Schema.VideoPlayer(from: decoder))
            )
        case .row:
            try self.init(
                properties: propertyOrNil(),
                node: .compositeElement(Schema.Row(from: decoder, configuration: configuration))
            )
        case .column:
            try self.init(
                properties: propertyOrNil(),
                node: .compositeElement(Schema.Column(from: decoder, configuration: configuration))
            )
        case .section:
            try self.init(
                properties: propertyOrNil(),
                node: .compositeElement(Schema.Section(from: decoder, configuration: configuration))
            )
        case .toggle:
            try self.init(
                properties: propertyOrNil(),
                node: .simpleElement(Schema.Toggle(from: decoder, configuration: configuration))
            )
        case .slider:
            try self.init(
                properties: propertyOrNil(),
                node: .simpleElement(Schema.Slider(from: decoder))
            )
        case .timer:
            try self.init(
                properties: propertyOrNil(),
                node: .simpleElement(Schema.Timer(from: decoder, configuration: configuration))
            )
        case .pager:
            try self.init(
                properties: propertyOrNil(),
                node: .compositeElement(Schema.Pager(from: decoder, configuration: configuration))
            )
        case .compactDateTimePicker, .graphicalDateTimePicker, .wheelDateTimePicker:
            try self.init(
                properties: propertyOrNil(),
                node: .simpleElement(Schema.DateTimePicker(from: decoder))
            )
        case .wheelRangePicker:
            try self.init(
                properties: propertyOrNil(),
                node: .simpleElement(Schema.WheelRangePicker(from: decoder))
            )
        case .wheelItemsPicker:
            try self.init(
                properties: propertyOrNil(),
                node: .simpleElement(Schema.WheelItemsPicker(from: decoder))
            )
        }

        func propertyOrNil() -> Schema.ElementProperties? {
            guard let properties = try? Schema.ElementProperties(from: decoder, configuration: configuration) else { return nil }
            return properties.isEmpty ? nil : properties
        }
    }

    func encode(to _: any Encoder) throws {
        // TODO: implement
    }
}
