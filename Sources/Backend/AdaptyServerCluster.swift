//
//  AdaptyServerCluster.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.11.2024.
//

public enum AdaptyServerCluster: Sendable {
    case `default`
    case eu
    case cn
    case other(String)

    static var all: [Self] {
        [.default, .eu, .cn]
    }
}

extension AdaptyServerCluster: LosslessStringConvertible {
    private enum StringValue: String {
        case `default`
        case eu
        case cn
    }

    public init?(_ value: String) {
        let value = value.trimmed.lowercased()
        self = switch StringValue(rawValue: value) {
        case .default: .default
        case .eu: .eu
        case .cn: .cn
        default: .other(value)
        }
    }

    public var description: String {
        let value: StringValue
        switch self {
        case .default: value = .default
        case .eu: value = .eu
        case .cn: value = .cn
        case .other(let value):
            return value
        }
        return value.rawValue
    }
}

extension AdaptyServerCluster: Hashable {
    public func hash(into hasher: inout Hasher) {
        description.hash(into: &hasher)
    }
}

extension AdaptyServerCluster: Codable {
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self = AdaptyServerCluster(value) ?? .default
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
