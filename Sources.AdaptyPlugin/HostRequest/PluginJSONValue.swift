//
//  PluginJSONValue.swift
//  AdaptyPlugin
//

import Foundation

/// Minimal JSON value for encoding arbitrary `[String: any Sendable]` flow analytics params.
enum PluginJSONValue: Encodable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([PluginJSONValue])
    case object([String: PluginJSONValue])
    case null

    init(_ value: Any?) {
        switch value {
        case let v as Bool: self = .bool(v) // check Bool before Int (NSNumber bridging)
        case let v as Int: self = .int(v)
        case let v as Double: self = .double(v)
        case let v as String: self = .string(v)
        case let v as [Any?]: self = .array(v.map(PluginJSONValue.init))
        case let v as [String: Any?]: self = .object(v.mapValues(PluginJSONValue.init))
        case let v as [String: Any]: self = .object(v.mapValues(PluginJSONValue.init))
        default: self = .null
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(v): try container.encode(v)
        case let .int(v): try container.encode(v)
        case let .double(v): try container.encode(v)
        case let .bool(v): try container.encode(v)
        case let .array(v): try container.encode(v)
        case let .object(v): try container.encode(v)
        case .null: try container.encodeNil()
        }
    }
}
