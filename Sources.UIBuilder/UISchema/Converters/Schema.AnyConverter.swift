//
//  Schema.AnyConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.04.2026.
//

import Foundation

extension Schema {
    typealias AnyConverter = VC.AnyConverter
}

extension Schema.AnyConverter {
    enum CodingKeys: String, CodingKey {
        case converter
        case converterParameters = "converter_params"
    }

    private enum DataBindingConvertorName: String {
        case isEqual = "is_equal"
        case map
    }

    private enum TagConvertorName: String {
        case dateTime = "date_time"
        case percent
        case number
    }

    static func forDataBinding(from decoder: any Decoder) throws -> Schema.AnyConverter {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .converter)
        return switch DataBindingConvertorName(rawValue: name) {
        case .isEqual:
            try Schema.IsEqualConverter(from: decoder).asAnyConverter
        case .map:
            try Schema.MapConverter(from: decoder).asAnyConverter
        default:
            VC.UnknownConverter(name: name).asAnyConverter
        }
    }

    static func forTag(from decoder: any Decoder) throws -> Schema.AnyConverter {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .converter)
        return switch TagConvertorName(rawValue: name) {
        case .dateTime:
            try Schema.DateTimeConverter(from: decoder).asAnyConverter
        case .number:
            try Schema.NumberConverter(from: decoder).asAnyConverter
        case .percent:
            try Schema.PercentConverter(from: decoder).asAnyConverter
        default:
            if let converter = (try? Schema.TimerConverter(from: decoder)) {
                converter.asAnyConverter
            } else {
                VC.UnknownConverter(name: name).asAnyConverter
            }
        }
    }
}

