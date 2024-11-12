//
//  AdaptyPaywall+ViewConfiguration.swift.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 10.04.2024
//
//

import Foundation

extension AdaptyPaywall {
    enum ViewConfiguration: Sendable, Hashable {
        case withoutData(AdaptyLocale, String)
        case data(AdaptyUICore.ViewConfiguration)

        var hasData: Bool {
            switch self {
            case .data: true
            default: false
            }
        }

        var responseLocale: AdaptyLocale {
            switch self {
            case let .withoutData(value, _): value
            case let .data(data): data.responseLocale
            }
        }

        var id: String {
            switch self {
            case let .withoutData(_, value): value
            case let .data(data): data.id
            }
        }
    }
}

extension AdaptyPaywall.ViewConfiguration: Codable {
    typealias CodingKeys = AdaptyUICore.ViewConfiguration.ContainerCodingKeys

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self =
            if container.contains(.container) {
                try .data(AdaptyUICore.ViewConfiguration(from: decoder))
            } else {
                try .withoutData(
                    container.decode(AdaptyLocale.self, forKey: .responseLocale),
                    container.decode(String.self, forKey: .id)
                )
            }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(responseLocale, forKey: .responseLocale)
        try container.encode(id, forKey: .id)
    }
}
