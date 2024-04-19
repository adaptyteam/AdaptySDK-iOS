//
//  AdaptyPaywall+ViewConfiguration.swift.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 10.04.2024
//
//

import Foundation

extension AdaptyPaywall {
    enum ViewConfiguration {
        case withoutData(AdaptyLocale, String)
        case data(AdaptyUI.ViewConfiguration)

        var hasData: Bool {
            switch self {
            case .data: true
            default: false
            }
        }

        var locale: AdaptyLocale {
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
    enum CodingKeys: String, CodingKey {
        case id = "paywall_builder_id"
        case locale = "lang"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self = try .withoutData(
            container.decode(AdaptyLocale.self, forKey: .locale),
            container.decode(String.self, forKey: .id)
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(locale, forKey: .locale)
        try container.encode(id, forKey: .id)
    }
}
