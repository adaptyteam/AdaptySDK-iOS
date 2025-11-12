//
//  NetworkConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.10.2025.
//

import Foundation

struct NetworkConfiguration: Sendable {
    let eventBlacklist: Set<String>
    let mainBaseUrls: [AdaptyServerCluster: [URL]]
    let expiresIn: TimeInterval
    let extendSeconds: TimeInterval
}

extension NetworkConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case eventBlacklist = "event_blacklist"
        case mainBaseUrls = "api_endpoints"
        case expiresIn = "expires_in"
        case extendSeconds = "retry_interval"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eventBlacklist = try container.decode(Set<String>.self, forKey: .eventBlacklist)
        self.mainBaseUrls = try container.decode([AdaptyServerCluster: [URL]].self, forKey: .mainBaseUrls)
        self.expiresIn = try container.decode(Double.self, forKey: .expiresIn) / 1000.0
        self.extendSeconds = try container.decode(Double.self, forKey: .extendSeconds) / 1000.0
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventBlacklist, forKey: .eventBlacklist)
        try container.encode(mainBaseUrls, forKey: .mainBaseUrls)
        try container.encode(Int64(expiresIn * 1000), forKey: .expiresIn)
        try container.encode(Int64(extendSeconds * 1000), forKey: .extendSeconds)
    }
}
