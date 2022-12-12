//
//  AdaptyProfile.Gender.swift
//  Adapty
//
//  Created by Aleksei Valiano on 26.09.2022.
//

import Foundation

extension AdaptyProfile {
    public enum Gender {
        case female
        case male
        case other
    }
}

extension AdaptyProfile.Gender: CustomStringConvertible {
    public var description: String {
        switch self {
        case .female: return "female"
        case .male: return "male"
        case .other: return "other"
        }
    }
}

extension AdaptyProfile.Gender: Equatable, Sendable {}

extension AdaptyProfile.Gender: Codable {
    enum CodingValues: String {
        case female = "f"
        case male = "m"
        case other = "o"
    }

    public init(from decoder: Decoder) throws {
        let value = CodingValues(rawValue: try decoder.singleValueContainer().decode(String.self))
        switch value {
        case .female: self = .female
        case .male: self = .male
        case .other: self = .other
        default: self = .other
        }
    }

    public func encode(to encoder: Encoder) throws {
        let value: CodingValues
        switch self {
        case .female: value = .female
        case .male: value = .male
        case .other: value = .other
        }
        var container = encoder.singleValueContainer()
        try container.encode(value.rawValue)
    }
}
