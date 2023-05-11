//
//  AdaptyEligibility.swift
//  Adapty
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

public enum AdaptyEligibility {
    case unknown
    case ineligible
    case eligible
    case notApplicable
}

//extension AdaptyEligibility: ExpressibleByBooleanLiteral, ExpressibleByNilLiteral {
//    public init(booleanLiteral value: Bool) {
//        self = value ? .eligible : .ineligible
//    }
//
//    public init(nilLiteral: ()) {
//        self = .unknown
//    }
//}
//
//extension AdaptyEligibility: CustomStringConvertible {
//    public var description: String {
//        switch self {
//        case .unknown: return "unknown"
//        case .ineligible: return "ineligible"
//        case .eligible: return "eligible"
//        case .notApplicable: return "not_applicable"
//        }
//    }
//}

extension AdaptyEligibility: Equatable, Sendable {}

extension AdaptyEligibility: Codable {
    enum CodingValues: String {
        case unknown
        case ineligible
        case eligible
        case notApplicable = "not_applicable"
    }

    public init(from decoder: Decoder) throws {
        let value = CodingValues(rawValue: try decoder.singleValueContainer().decode(String.self))
        switch value {
        case .unknown: self = .unknown
        case .ineligible: self = .ineligible
        case .eligible: self = .eligible
        case .notApplicable: self = .notApplicable
        default: self = .unknown
        }
    }

    public func encode(to encoder: Encoder) throws {
        let value: CodingValues
        switch self {
        case .unknown: value = .unknown
        case .ineligible: value = .ineligible
        case .eligible: value = .eligible
        case .notApplicable: value = .notApplicable
        }
        var container = encoder.singleValueContainer()
        try container.encode(value.rawValue)
    }
}
