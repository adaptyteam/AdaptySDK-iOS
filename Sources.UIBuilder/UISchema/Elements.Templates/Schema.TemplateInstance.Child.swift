//
//  Schema.templateInstance.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 10.02.2026.
//

import Foundation

extension Schema.TemplateInstance {
    enum Child: Sendable, Hashable {
        case element(Schema.Element)
        case array([Self])

        case gridItem(Schema.GridItem)
        case stackSpace(Int)

        case null
        case bool(Bool)
        case int(Int)
        case uint(UInt)
        case double(Double)
        case string(String)
        case unknown
    }
}

extension Schema.TemplateInstance.Child: Encodable, DecodableWithConfiguration {


    init(from decoder: any Decoder, configuration: DecodingConfiguration) throws {
        if let container = try? decoder.singleValueContainer(),
           let v = try container.decodeChild()
        {
            self = v
            return
        }

        if let container = try? decoder.container(keyedBy: CodingKeys.self), container.contains(.type) {
            self = try .element(Schema.Element(from: decoder, configuration: configuration))
        }

        decoder.singleValueContainer()

        if let container = try? decoder.container(keyedBy: CodingKeys.self)

        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            if container.contains(.type) {
                self = try .one(container.decode(Schema.Element.self, forKey: .type, configuration: configuration))
                return
            }
        }

        if let container = try? decoder.container(keyedBy: CodingKeys.self, forKey: key) {
            if
        }
        if container.contains(.type) {
            childs[key.stringValue] = try .one(container.decode(Schema.Element.self, forKey: key, configuration: configuration))
            continue
        }

        if var arrayContainer = try? container.nestedUnkeyedContainer(forKey: key) {
            if let firstElement = try? arrayContainer.nestedContainer(keyedBy: CodingKeys.self),
               firstElement.contains(.type)
            {
                childs[key.stringValue] = try .array(container.decode([Schema.Element].self, forKey: key, configuration: configuration))
            }
        }
    }

    private static func decodeChild(from decoder: any Decoder, configuration: DecodingConfiguration) throws -> Self? {

        enum CodingKeys: String, CodingKey {
            case type
        }

        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return nil }
        if container.contains(.type) {
            return try .element(Schema.Element(from: decoder, configuration: configuration))
        } else if container.contains(.content) {
            return try .gri (Schema.Element(from: decoder, configuration: configuration))

        }

        return nil
    }


    func encode(to encoder: any Encoder) throws {
        // TODO: implement after Element encodable
    }
}



private extension SingleValueDecodingContainer {
    func decodeChild() throws -> Schema.TemplateInstance.Child? {
        if decodeNil() {
            .null
        } else if let v = try? decode(Bool.self) {
            .bool(v)
        } else if let v = try? decode(Int.self) {
            .int(v)
        } else if let v = try? decode(UInt.self) {
            .uint(v)
        } else if let v = try? decode(Double.self) {
            .double(v)
        } else if let v = try? decode(String.self) {
            .string(v)
        } else {
            nil
        }
    }
}
