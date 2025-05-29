//
//  OnboardingsInputParams+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 28.05.2025.
//

import AdaptyUI
import Foundation

extension OnboardingsInputParams: Encodable {
    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let value):
            try container.encode("text", forKey: .type)
            try container.encode(value, forKey: .value)
        case .email(let value):
            try container.encode("email", forKey: .type)
            try container.encode(value, forKey: .value)
        case .number(let value):
            try container.encode("number", forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
}
