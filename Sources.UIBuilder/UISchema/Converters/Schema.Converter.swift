//
//  Schema.Converter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.04.2026.
//

import Foundation


extension Schema {
    enum Converter {
        enum CodingKeys: String, CodingKey {
            case converter
            case converterParameters = "converter_params"
        }

        private enum DataBindingConverterName: String {
            case isEqual = "is_equal"
            case map
        }

        private enum TagValueConverterName: String {
            case dateTime = "date_time"
            case percent
            case number
        }

        static func dataBindingConverter(from decoder: any Decoder) throws -> JSDataBindingConverter? {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let name = try container.decode(String.self, forKey: .converter)
            return switch DataBindingConverterName(rawValue: name) {
            case .isEqual:
                try Schema.IsEqualConverter(from: decoder)
            case .map:
                try Schema.MapConverter(from: decoder)
            default:
                nil
            }
        }

        static func tagValueConverter(from decoder: any Decoder) throws -> AdaptyUITagValueConverter? {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let name = try container.decode(String.self, forKey: .converter)
            switch TagValueConverterName(rawValue: name) {
            case .dateTime:
                return try Schema.DateTimeConverter(from: decoder)
            case .number:
                return try Schema.NumberConverter(from: decoder)
            case .percent:
                return try Schema.PercentConverter(from: decoder)
            default:
                if let converter = (try? Schema.TimerConverter(from: decoder)) {
                    return converter
                } else {
                    return nil
                }
            }
        }
    }
}
