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
        case value(AdaptyViewSource)
        case json(AdaptyLocale, id: String, json: Data?)
    }
}

extension AdaptyPaywall.ViewConfiguration {
    var responseLocale: AdaptyLocale {
        switch self {
        case let .json(locale, _, _): locale
        case let .value(value): value.responseLocale
        }
    }

    var id: String {
        switch self {
        case let .json(_, id, _): id
        case let .value(value): value.id
        }
    }
}

extension AdaptyViewSource {
    init(data: Data) throws {
        do {
            self = try Storage.decoder.decode(AdaptyViewSource.self, from: data)
        } catch {
            throw AdaptyError.decodingViewConfiguration(error)
        }
    }
}

extension AdaptyPaywall.ViewConfiguration: Codable {
    typealias CodingKeys = AdaptyViewSource.ContainerCodingKeys

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self =
            if container.contains(.container) {
                try .value(AdaptyViewSource(from: decoder))
            } else {
                try .json(
                    container.decode(AdaptyLocale.self, forKey: .responseLocale),
                    id: container.decode(String.self, forKey: .id),
                    json: container.decodeIfPresent(String.self, forKey: .json)?.data(using: .utf8)
                )
            }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .json(locale, id, json):
            try container.encode(locale, forKey: .responseLocale)
            try container.encode(id, forKey: .id)
            if encoder.userInfo.enabledEncodingViewConfiguration {
                let json = json.flatMap { String(data: $0, encoding: .utf8) }
                try container.encodeIfPresent(json, forKey: .json)
            }
        case let .value(value):
            try container.encode(value.responseLocale, forKey: .responseLocale)
            try container.encode(value.id, forKey: .id)
            if encoder.userInfo.enabledEncodingViewConfiguration {
                let json = try String(data: Storage.encoder.encode(value), encoding: .utf8)
                try container.encodeIfPresent(json, forKey: .json)
            }
        }
    }
}
