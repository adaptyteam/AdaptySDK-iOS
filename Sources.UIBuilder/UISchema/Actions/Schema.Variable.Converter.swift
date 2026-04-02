//
//  Schema.Variable.Converter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 24.02.2026.
//

import Foundation

extension Schema.Variable.Converter: Codable {
    private enum CodingKeys: String, CodingKey {
        case name = "converter"
        case params = "converter_params"
    }

    private enum Names: String, Codable {
        case isEqual = "is_equal"
        case dateTime = "date_time"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .name)
        var params = try container.decodeIfPresent(VC.Parameter.self, forKey: .params)
        if case .null = params { params = nil }

        switch Names(rawValue: name) {
        case .isEqual:
            guard let params else {
                throw DecodingError.keyNotFound(CodingKeys.params, .init(codingPath: container.codingPath, debugDescription: "Required key '\(CodingKeys.params.stringValue)' not found for 'is_equal' converter"))
            }

            switch params {
            case let .object(object):
                guard let value = object["value"], value != .null else {
                    throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath + [CodingKeys.params], debugDescription: "Missing required 'value' key in 'is_equal' converter params"))
                }

                self = .isEqual(value, falseValue: object["false_value"])
            default:
                self = .isEqual(params, falseValue: nil)
            }

        case .dateTime:
            guard let params else {
                throw DecodingError.keyNotFound(CodingKeys.params, .init(codingPath: container.codingPath, debugDescription: "Required key '\(CodingKeys.params.stringValue)' not found for 'date_time' converter"))
            }

            switch params {
            case let .object(object):
                if let format = object["format"] {
                    if case let .string(value) = format {
                        self = .dateTimeWithFormat(value)
                        return
                    }
                    throw DecodingError.dataCorruptedError(forKey: .params, in: container, debugDescription: "The 'format' parameter must be a string in 'date_time' converter")
                }

                var dateStyle: DateFormatter.Style
                var timeStyle: DateFormatter.Style

                if let p = object["date"] {
                    if case let .string(v) = p, let value = DateFormatter.Style(fromString: v) {
                        dateStyle = value
                    } else {
                        throw DecodingError.dataCorruptedError(forKey: .params, in: container, debugDescription: "The 'date' parameter must be a string in 'date_time' converter")
                    }
                } else {
                    dateStyle = .none
                }

                if let p = object["time"] {
                    if case let .string(v) = p, let value = DateFormatter.Style(fromString: v) {
                        timeStyle = value
                    } else {
                        throw DecodingError.dataCorruptedError(forKey: .params, in: container, debugDescription: "The 'time' parameter must be a string in 'date_time' converter")
                    }
                } else {
                    timeStyle = .none
                }

                if dateStyle == .none, timeStyle == .none {
                    throw DecodingError.dataCorruptedError(forKey: .params, in: container, debugDescription: "At least one of 'date', 'time', or 'format' string parameters is required for 'date_time' converter")
                }

                self = .dateTimeWithStyle(dateStyle, timeStyle)
            case let .string(value):
                self = .dateTimeWithFormat(value)
            default:
                throw DecodingError.dataCorruptedError(forKey: .params, in: container, debugDescription: "Unsupported parameter type for 'date_time' converter: expected an object or a string")
            }

        case nil:
            self = try .unknown(name, params)
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .isEqual(value, falseValue):
            try container.encode(Names.isEqual, forKey: .name)
            let params: VC.Parameter =
                if let falseValue {
                    .object(["value": value, "false_value": falseValue])
                } else {
                    value
                }
            try container.encode(params, forKey: .params)
        case let .dateTimeWithFormat(format):
            try container.encode(Names.dateTime, forKey: .name)
            let params: VC.Parameter = .object(["format": .string(format)])
            try container.encode(params, forKey: .params)
        case let .dateTimeWithStyle(date, time):
            try container.encode(Names.dateTime, forKey: .name)
            let params: VC.Parameter = .object(["date": .string(date.stringValue), "time": .string(time.stringValue)])
            try container.encode(params, forKey: .params)
        case let .unknown(name, params):
            try container.encode(name, forKey: .name)
            try container.encodeIfPresent(params, forKey: .params)
        }
    }
}

