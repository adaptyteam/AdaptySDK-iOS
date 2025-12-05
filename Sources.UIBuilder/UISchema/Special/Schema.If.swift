//
//  Schema.If.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    struct If: DecodableWithConfiguration {
        let content: Schema.Element

        enum CodingKeys: String, CodingKey {
            case platform
            case version
            case then
            case `else`
        }

        init(from decoder: Decoder, configuration: DecodingConfiguration) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            content =
                if
                    try container.decodeIfPresent(String.self, forKey: .platform).map({ $0 == "ios" }) ?? true,
                    try container.decodeIfPresent(Version.self, forKey: .version).map(Schema.formatVersion.isSameOrNewerVersion) ?? true {
                    try container.decode(Schema.Element.self, forKey: .then, configuration: configuration)
                } else {
                    try container.decode(Schema.Element.self, forKey: .else, configuration: configuration)
                }
        }
    }
}
