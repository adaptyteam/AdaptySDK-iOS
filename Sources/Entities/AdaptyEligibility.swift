//
//  AdaptyEligibility.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

/// Defines offers eligibility state (e.g. introductory offers or promotional offers.)
public enum AdaptyEligibility {
    /// User is not eligible to get any offer, you should't present it in your UI.
    case ineligible

    /// User is eligible for intro offer, it is safe to reflect this info in you UI.
    case eligible

    /// This kind of product is not configured to have an offer.
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
        let value = try CodingValues(rawValue: decoder.singleValueContainer().decode(String.self))
        switch value {
        case .some(.ineligible): self = .ineligible
        case .some(.eligible): self = .eligible
        case .some(.notApplicable): self = .notApplicable
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "unknown value"))
        }
    }

    public var rawStringValue: String {
        let value: CodingValues =
            switch self {
            case .ineligible: .ineligible
            case .eligible: .eligible
            case .notApplicable: .notApplicable
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
