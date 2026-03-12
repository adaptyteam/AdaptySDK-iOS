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

extension Schema.TextField: Codable {
    enum CodingKeys: String, CodingKey {
        case value
        case placeholder
        case secureEntry = "secure_entry"
        case horizontalAlign = "align"
        case inputConstraints = "input_constraints"
        case validation
        case invalidTextAttributes = "invalid_attributes"
        case keyboardOptions = "keyboard_options"
//        case maxRows = "max_rows"
        case overflowMode = "on_overflow"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(Schema.Variable.self, forKey: .value)
        placeholder = try container.decodeIfPresent(Schema.TextField.Placeholder.self, forKey: .placeholder)
        secureEntry = try container.decodeIfPresent(Bool.self, forKey: .secureEntry) ?? false
        horizontalAlign = try container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading
        let constraints = try container.decodeIfPresent(Schema.TextField.InputConstraints.self, forKey: .inputConstraints)
        inputConstraints = constraints?.nonEmptyOrNil

        validation = try container.decode(Schema.Variable.self, forKey: .validation)

        let textAttributes = try Schema.Text.Attributes(from: decoder)
        defaultTextAttributes = textAttributes.nonEmptyOrNil

        if validation == nil {
            self.invalidTextAttributes = nil
        } else {
            let invalidTextAttributes = try container.decodeIfPresent(Schema.Text.Attributes.self, forKey: .invalidTextAttributes)
            self.invalidTextAttributes = invalidTextAttributes?.nonEmptyOrNil
        }

        let options = try container.decodeIfPresent(Schema.TextField.KeyboardOptions.self, forKey: .keyboardOptions)

        keyboardOptions = options?.nonEmptyOrNil
    }

    package func encode(to encoder: any Encoder) throws {
        if let defaultTextAttributes = defaultTextAttributes.nonEmptyOrNil {
            try defaultTextAttributes.encode(to: encoder)
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        if let placeholder {
            try container.encode(placeholder, forKey: .placeholder)
        }
        if secureEntry {
            try container.encode(secureEntry, forKey: .secureEntry)
        }
        if horizontalAlign != .leading {
            try container.encode(horizontalAlign, forKey: .horizontalAlign)
        }
        if let inputConstraints, !inputConstraints.isEmpty {
            try container.encode(inputConstraints, forKey: .inputConstraints)
        }
        if let validation {
            try container.encode(validation, forKey: .validation)

            if let invalidTextAttributes, !invalidTextAttributes.isEmpty {
                try container.encode(invalidTextAttributes, forKey: .invalidTextAttributes)
            }
        }

        if let keyboardOptions, !keyboardOptions.isEmpty {
            try container.encode(keyboardOptions, forKey: .keyboardOptions)
        }
    }
}
