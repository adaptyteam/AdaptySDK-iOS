//
//  Schema.PercentConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.04.2026.
//

import Foundation

extension Schema {
    typealias PercentConverter = VC.PercentConverter
}

extension Schema.PercentConverter: Decodable {
    private enum CodingKeys: String, CodingKey {
        case format
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent(String.self, forKeys: .format) {
            guard value.isValidNumberFormat else {
                throw DecodingError.dataCorruptedError(forKey: .format, in: container, debugDescription: "wrong format: \(value)")
            }
            format = value
        } else {
            format = "%d"
        }
    }
}



