//
//  Schema.TemplateInstance.swift
//  Adapty
//
//  Created by Aleksei Valiano on 09.02.2026.
//

import Foundation

extension Schema {
    struct TemplateInstance: Sendable, Hashable {
        let type: String
    }
}

extension Schema.TemplateInstance: Encodable, DecodableWithConfiguration {
    enum CodingKeys: String, CodingKey {
        case type
    }

    package init(from decoder: Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        guard type.hasPrefix(Schema.Template.keyPrefix), type.count < 2 else {
            throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "Wrong type format for template instance \(type)"))
        }

        self.init(
            type: String(type.dropFirst())
        )
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("#" + type, forKey: .type)
    }
}
