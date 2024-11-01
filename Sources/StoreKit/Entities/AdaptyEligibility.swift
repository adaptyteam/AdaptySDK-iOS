//
//  AdaptyEligibility.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

enum AdaptyEligibility: Sendable, Hashable {
    case ineligible
    case eligible
    case notApplicable
}

extension AdaptyEligibility: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: Bool) {
        self = value ? .eligible : .ineligible
    }
}

extension AdaptyEligibility: Codable {
    enum CodingValues: String {
        case ineligible
        case eligible
        case notApplicable = "not_applicable"
    }

    init(from decoder: Decoder) throws {
        let value = try CodingValues(rawValue: decoder.singleValueContainer().decode(String.self))
        switch value {
        case .some(.ineligible): self = .ineligible
        case .some(.eligible): self = .eligible
        case .some(.notApplicable): self = .notApplicable
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "unknown value"))
        }
    }

    var rawStringValue: String {
        let value: CodingValues =
            switch self {
            case .ineligible: .ineligible
            case .eligible: .eligible
            case .notApplicable: .notApplicable
            }
        return value.rawValue
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawStringValue)
    }
}

extension AdaptyEligibility: CustomStringConvertible {
    var description: String { rawStringValue }
}
