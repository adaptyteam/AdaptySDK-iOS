//
//  JSONValue.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 22.11.2022
//

@testable import Adapty
import Foundation

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
        case .null: return true
        default: return false
        }
    }

    var asStringOrNil: String? {
        switch self {
        case let .string(value): return value
        default: return nil
        }
    }

    var asIntOrNil: Int? {
        switch self {
        case let .int(value): return value
        default: return nil
        }
    }

    var asFloatOrNil: Double? {
        switch self {
        case let .float(value): return value
        case let .int(value): return Double(value)
        default: return nil
        }
    }

    var asBoolOrNil: Bool? {
        switch self {
        case let .bool(value): return value
        default: return nil
        }
    }

    var asArrayOrNil: [JSONValue]? {
        switch self {
        case let .array(value): return value
        default: return nil
        }
    }

    var asObjectOrNil: [String: JSONValue]? {
        switch self {
        case let .object(value): return value
        default: return nil
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
    init(nilLiteral: ()) {
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
        let encoder = Backend.encoder
        if let outputFormatting = outputFormatting {
            encoder.outputFormatting = outputFormatting
        }
        return try jsonData(encoder: encoder)
    }

    func jsonData(encoder: JSONEncoder) throws -> Data {
        try encoder.encode(self)
    }

    func jsonString(outputFormatting: JSONEncoder.OutputFormatting? = nil) throws -> String {
        guard let string = String(data: try jsonData(outputFormatting: outputFormatting), encoding: .utf8) else {
            throw JSONValueError.stringNoBeParsedFromData
        }
        return string
    }
}

extension Data {
    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        return try Backend.decoder.decode(type, from: self)
    }
}
