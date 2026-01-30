//
//  Schema.Template.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 02.12.2025.
//

import Foundation

extension Schema {
    struct Template: Sendable, Hashable {
        let content: Element
    }
}

extension Schema.Template {
    static let keyPrefix: String = "$"
}

extension Schema.Template: Encodable, DecodableWithConfiguration {
    private enum CodingKeys: String, CodingKey {
        case content
    }

    init(from decoder: any Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try self.init(
            content: container.decode(Schema.Element.self, forKey: .content, configuration: configuration)
        )
    }
}
