//
//  Schema.RTLBehavior.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 21.08.2026.


import Foundation

extension Schema {
    struct RTLBehavior: Sendable {
        let mirrorInRTL: Bool
    }
}

extension Schema.RTLBehavior: Decodable {

    static let `default` = Self(mirrorInRTL: false)
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value.lowercased() {
        case "preserve", "keep":
            self = .init(mirrorInRTL: false)
        case "mirror":
            self = .init(mirrorInRTL: true)
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unexpected RTLBehavior value: \(value)")
        }
    }
}
