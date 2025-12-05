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
            case startVersion = "version"
            case endVersion = "to_version"
            case then
            case `else`
        }

        init(from decoder: Decoder, configuration: DecodingConfiguration) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            var result = try container.decodeIfPresent(String.self, forKey: .platform).map { $0 == "ios" } ?? true

            if result, let startVersion = try container.decodeIfPresent(String.self, forKey: .startVersion) {
                result = Schema.formatVersion.isSameOrNewerVersion(than: startVersion)
            }

            if result, let endVersion = try container.decodeIfPresent(String.self, forKey: .endVersion) {
                result = !endVersion.isSameOrNewerVersion(than: Schema.formatVersion)
            }

            content = try container.decode(Schema.Element.self, forKey: result ? .then : .else)
        }
    }
}
