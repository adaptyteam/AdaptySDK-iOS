//
//  Schema.NumberConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 21.04.2026.
//

import Foundation

extension Schema {
    typealias NumberConverter = VC.NumberConverter
}

extension Schema.NumberConverter: Decodable {
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

extension String {
    var isValidNumberFormat: Bool {
        let pattern = #"^%[+\-0 ]*(\d+)?(\.\d+)?[df]$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    var isValidIntegerFormat: Bool {
        let pattern = #"^%[+\-0 ]*(\d+)?(\.\d+)?d$"#
        return range(of: pattern, options: .regularExpression) != nil
    }
}

