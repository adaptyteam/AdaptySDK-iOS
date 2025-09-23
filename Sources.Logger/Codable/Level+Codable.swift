//
//  Level+Codable.swift
//  AdaptyLogger
//
//  Created by Aleksei Valiano on 22.08.2024
//

import Foundation

extension AdaptyLogger.Level: Codable {
    public init(from decoder: Decoder) throws {
        self = try AdaptyLogger.Level(stringLiteral: decoder.singleValueContainer().decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringLiteral)
    }
}
