//
//  JSONValue.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 22.11.2022
//

import Foundation
@testable import Adapty

enum JSONValue: Equatable, Encodable {
    case null
    case string(String)
    case int(Int)
    case float(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])

    var isNull: Bool {
        switch self {
        case .null: true
        default: false
        }
    }

    var asStringOrNil: String? {
        switch self {
        case let .string(value): value
        default: nil
        }
    }

    var asIntOrNil: Int? {
        switch self {
        case let .int(value): value
        default: nil
        }
    }

    var asFloatOrNil: Double? {
        switch self {
        case let .float(value): value
        case let .int(value): Double(value)
        default: nil
        }
    }

    var asBoolOrNil: Bool? {
        switch self {
        case let .bool(value): value
        default: nil
        }
    }

    var asArrayOrNil: [JSONValue]? {
        switch self {
        case let .array(value): value
        default: nil
        }
    }

    var asObjectOrNil: [String: JSONValue]? {
        switch self {
        case let .object(value): value
        default: nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case let .string(value): try container.encode(value)
        case let .int(value): try container.encode(value)
        case let .float(value): try container.encode(value)
        case let .bool(value): try container.encode(value)
        case let .object(value): try container.encode(value)
        case let .array(value): try container.encode(value)
        }
    }
}

extension JSONValue: ExpressibleByNilLiteral,
    ExpressibleByStringLiteral,
    ExpressibleByIntegerLiteral,
    ExpressibleByFloatLiteral,
    ExpressibleByBooleanLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral {
    init(nilLiteral _: ()) {
        self = .null
    }

    init(stringLiteral value: String) {
        self = .string(value)
    }

    init(integerLiteral value: Int) {
        self = .int(value)
    }

    init(floatLiteral value: Double) {
        self = .float(value)
    }

    init(booleanLiteral value: Bool) {
        self = .bool(value)
    }

    init(arrayLiteral elements: JSONValue...) {
        self = .array(elements)
    }

    init(dictionaryLiteral elements: (String, JSONValue)...) {
        self = .object(Dictionary(uniqueKeysWithValues: elements))
    }

    static func timestamp(_ value: Date) -> JSONValue {
        .int(Int(value.timeIntervalSince1970 * 1000))
    }
}

enum JSONValueError: Error {
    case stringNoBeParsedFromData
}

extension JSONValue {
    func jsonData(outputFormatting: JSONEncoder.OutputFormatting? = nil) throws -> Data {
        let encoder = JSONEncoder()
        Backend.configure(encoder: encoder)
        if let outputFormatting {
            encoder.outputFormatting = outputFormatting
        }
        return try jsonData(encoder: encoder)
    }

    func jsonData(encoder: JSONEncoder) throws -> Data {
        try encoder.encode(self)
    }

    func jsonString(outputFormatting: JSONEncoder.OutputFormatting? = nil) throws -> String {
        guard let string = try String(data: jsonData(outputFormatting: outputFormatting), encoding: .utf8) else {
            throw JSONValueError.stringNoBeParsedFromData
        }
        return string
    }
}

extension Data {
    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        Backend.configure(decoder: decoder)
        return try decoder.decode(type, from: self)
    }
}
