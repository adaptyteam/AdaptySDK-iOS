//
//  AdaptyConfiguration.TransactionFinishBehavior.swift
//  AdaptySD
//
//  Created by Aleksei Valiano on 07.09.2025.
//

public extension AdaptyConfiguration {
    enum TransactionFinishBehavior: Sendable {
        public static let `default` = TransactionFinishBehavior.auto
        case auto
        case manual
    }
}

extension AdaptyConfiguration.TransactionFinishBehavior: CustomStringConvertible {
    var rawValue: String {
        switch self {
        case .auto:
            "auto"
        case .manual:
            "manual"
        }
    }

    public var description: String {
        rawValue
    }
}

extension AdaptyConfiguration.TransactionFinishBehavior: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "auto":
            self = .auto
        case "manual":
            self = .manual
        case "default":
            self = .default
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown value: \(value)")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
