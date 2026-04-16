//
//  Schema.Variable.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.01.2026.
//

import Foundation

extension Schema {
    typealias Variable = VC.Variable
}

extension Schema.Variable: Decodable {
    enum CodingKeys: String, CodingKey {
        case path = "var"
        case setter
        case scope
        case converter
        case converterParameters = "converter_params"
    }

    private enum ConvertorName: String {
        case isEqual = "is_equal"
        case map
        case dateTime = "date_time"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let path = try container.decode(String.self, forKey: .path)

        var convertor: (any VC.Variable.Converter)? = nil

        if let convertorName = try container.decodeIfPresent(String.self, forKey: .converter) {
            switch ConvertorName(rawValue: convertorName) {
            case .isEqual:
                convertor = try Schema.Variable.IsEqualConvertor(from: decoder)
            case .map:
                convertor = try Schema.Variable.MapConvertor(from: decoder)
            case .dateTime:
                convertor = try Schema.Variable.DateTimeConvertor(from: decoder)
            default:
                convertor = UnknownConverter(name: convertorName)
            }
        }

        try self.init(
            path: path.split(separator: ".").map(String.init),
            setter: container.decodeIfPresent(String.self, forKey: .setter),
            scope: container.decodeIfPresent(Schema.Context.self, forKey: .scope) ?? .default,
            converter: convertor
        )
    }
}

