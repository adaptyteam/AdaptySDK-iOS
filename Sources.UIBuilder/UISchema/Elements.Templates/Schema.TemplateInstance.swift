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
//        let childs: [String: Child]?
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
            type: String(type.dropFirst()) // ,
//            childs: Self.decodeChilds(container: container, configuration: configuration)
        )
    }

//
//    private static func decodeChilds(
//        container: KeyedDecodingContainer<CodingKeys>,
//        configuration: Schema.DecodingConfiguration
//    ) throws -> [String: Child]? {
//        var childs: [String: Child] = [:]
//
//        for key in container.allKeys {
//            if let nested = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: key),
//               nested.contains(.type)
//            {
//                childs[key.stringValue] = try .element(container.decode(Schema.Element.self, forKey: key, configuration: configuration))
//                continue
//            }
//
//            if var arrayContainer = try? container.nestedUnkeyedContainer(forKey: key) {
//                if let firstElement = try? arrayContainer.nestedContainer(keyedBy: CodingKeys.self),
//                   firstElement.contains(.type)
//                {
//                    childs[key.stringValue] = try .array(container.decode([Schema.Element].self, forKey: key, configuration: configuration))
//                }
//            }
//        }
//
//        return childs.isEmpty ? nil : childs
//    }

    package func encode(to encoder: any Encoder) throws {
        // TODO: implement after Element encodable
    }
}
