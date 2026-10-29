//
//  Schema.CustomElement.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.08.2026.
//

import Foundation

extension Schema {
    struct CustomElement: Sendable {
        let id: String
        let type: String
        let assets: [String: AssetReference]?
        let strings: [String: StringReference]?
        let bindings: [String: Variable]?
        let payload: String?
        let fallback: Schema.Element?
    }
}

extension Schema.CustomElement: SchemaCompositeElement {
    @inlinable
    func planTasks(in taskStack: inout Schema.ConfigurationBuilder.TasksStack) {
        if let fallback {
            taskStack.append(.planElement(fallback))
        }
    }

    @inlinable
    func buildElement(
        _ builder: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?,
        _ elementIndices: inout [VC.ElementIndex]
    ) throws(Schema.Error) -> VC.Element {
        try .custom(
            builder.buildCustomElement(self, &elementIndices),
            properties
        )
    }
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func buildCustomElement(
        _ from: Schema.CustomElement,
        _ elementIndices: inout [VC.ElementIndex]
    ) throws(Schema.Error) -> VC.CustomElement {
        try .init(
            id: from.id,
            type: from.type,
            assets: from.assets,
            strings: from.strings,
            bindings: from.bindings,
            payload: from.payload,
            fallback: elementIndices.pop(from.fallback != nil)
        )
    }
}

extension Schema.CustomElement: DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case id = "custom_id"
        case type = "custom_type"
        case assets
        case strings
        case bindings
        case payload
        case fallback
    }

    init(from decoder: Decoder, configuration: Schema.InternalDecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            id: container.decode(String.self, forKey: .id),
            type: container.decode(String.self, forKey: .type),
            assets: container.decodeIfPresent([String: Schema.AssetReference].self, forKey: .assets),
            strings: container.decodeIfPresent([String: Schema.StringReference].self, forKey: .strings),
            bindings: container.decodeIfPresent([String: Schema.Variable].self, forKey: .bindings),
            payload: container.decodeIfPresent(String.self, forKey: .payload),
            fallback: container.decodeIfExist(Schema.Element.self, forKey: .fallback, configuration: configuration)
        )
    }
}
