//
//  AdaptyEligibility.swift
//  Adapty
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

public enum AdaptyEligibility {
    case ineligible
    case eligible
    case notApplicable
}

extension AdaptyEligibility: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = value ? .eligible : .ineligible
    }
}

extension AdaptyEligibility: Equatable, Sendable {}

extension AdaptyEligibility: Codable {
    enum CodingValues: String {
        case ineligible
        case eligible
        case notApplicable = "not_applicable"
    }

    public init(from decoder: Decoder) throws {
        let value = CodingValues(rawValue: try decoder.singleValueContainer().decode(String.self))
        switch value {
        case .some(.ineligible): self = .ineligible
        case .some(.eligible): self = .eligible
        case .some(.notApplicable): self = .notApplicable
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "unknown value"))
        }
    }

    public var rawStringValue: String {
        let value: CodingValues
        switch self {
        case .ineligible: value = .ineligible
        case .eligible: value = .eligible
        case .notApplicable: value = .notApplicable
        }
        return value.rawValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawStringValue)
    }
}

extension AdaptyEligibility: CustomStringConvertible {
    public var description: String { rawStringValue }
}
