//
//  AdaptyUILocalizationStrategy+Decodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 18.11.2026.
//

import Foundation
import AdaptyUIBuilder

extension AdaptyUILocalizationStrategy: Decodable {
    public init (from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "system":
            self = .system
        case "legacy":
            self = .legacy
        case "identity":
            self = .identity
        default:
            self = .default
        }
    }
}
