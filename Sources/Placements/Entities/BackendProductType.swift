//
//  BackendProductType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.07.2025.
//

enum BackendProductType: Sendable {
    case unknown(String?)
}

extension BackendProductType: Hashable {}

extension BackendProductType: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        let value = try container.decode(String.self)

        switch value {
        case "unknown":
            self = .unknown(nil)
        default:
            self = .unknown(value)
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .unknown(let value):
            try container.encode(value ?? "unknown")
        }
    }
}
