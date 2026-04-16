//
//  Schema.TextField.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.01.2026.
//

import Foundation

extension Schema {
    typealias TextField = VC.TextField
}

extension Schema.TextField: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        try .textField(self, properties)
    }
}

extension Schema.TextField: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case value
        case placeholder
        case secureEntry = "secure_entry"
        case horizontalAlign = "align"
        case inputConstraints = "input_constraints"
        case validation
        case invalidTextAttributes = "invalid_attributes"
        case keyboardOptions = "keyboard_options"
        case maxRows = "max_rows"
        case minRows = "min_rows"
        case overflowMode = "on_overflow"
        case keyboardSubmitActions = "submit_action"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(Schema.Element.ContentType.self, forKey: .type)
        kind = type == .textEditor ? .multiLine : .singleLine
        value = try container.decode(Schema.Variable.self, forKey: .value)
        placeholder = try container.decodeIfPresent(Schema.TextField.Placeholder.self, forKey: .placeholder)
        secureEntry = try container.decodeIfPresent(Bool.self, forKey: .secureEntry) ?? false
        horizontalAlign = try container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading
        let constraints = try container.decodeIfPresent(Schema.TextField.InputConstraints.self, forKey: .inputConstraints)
        inputConstraints = constraints?.nonEmptyOrNil

        validation = try container.decodeIfPresent(Schema.Variable.self, forKey: .validation)

        let textAttributes = try Schema.TextAttributes(from: decoder)
        defaultTextAttributes = textAttributes.nonEmptyOrNil

        if validation == nil {
            invalidTextAttributes = nil
        } else {
            let invalidTextAttributes = try container.decodeIfPresent(Schema.TextAttributes.self, forKey: .invalidTextAttributes)
            self.invalidTextAttributes = invalidTextAttributes?.nonEmptyOrNil
        }

        let options = try container.decodeIfPresent(Schema.TextField.KeyboardOptions.self, forKey: .keyboardOptions)

        keyboardOptions = options?.nonEmptyOrNil

        keyboardSubmitActions = try container.decodeIfPresentActions(forKey: .keyboardSubmitActions) ?? []

        if kind == .multiLine {
            maxRows = try container.decodeIfPresent(Int.self, forKey: .maxRows)
            minRows = try container.decodeIfPresent(Int.self, forKey: .minRows)
        } else {
            maxRows = nil
            minRows = nil
        }
    }

}
