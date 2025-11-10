//
//  NetworkState.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

struct NetworkState: Sendable {
    let eventBlacklist: Set<String>
    let baseUrls: [AdaptyServerCluster: [URL]]
    let expiresAt: Date
    let extendSeconds: TimeInterval
}

extension NetworkState {
    static func create(from: NetworkConfiguration, now: Date = Date()) -> Self {
        .init(
            eventBlacklist: from.eventBlacklist,
            baseUrls: from.baseUrls,
            expiresAt: now.addingTimeInterval(from.expiresIn),
            extendSeconds: from.extendSeconds
        )
    }

    func extended(now: Date = Date()) -> Self {
        .init(
            eventBlacklist: eventBlacklist,
            baseUrls: baseUrls,
            expiresAt: now.addingTimeInterval(extendSeconds),
            extendSeconds: extendSeconds
        )
    }

    var isExpired: Bool {
        expiresAt <= Date()
    }
}

extension NetworkState {
    func mainBaseUrl(by cluster: AdaptyServerCluster, withIndex index: Int) -> URL? {
        var baseUrls = self.baseUrls[cluster]
        if baseUrls == nil, cluster != .default {
            baseUrls = self.baseUrls[.default]
        }
        guard let baseUrls, baseUrls.isNotEmpty else { return nil }
        return baseUrls[min(index, baseUrls.endIndex)].appendingDefaultPathIfNeed
    }
}

extension NetworkState: Codable {
    enum CodingKeys: String, CodingKey {
        case eventBlacklist = "event_blacklist"
        case baseUrls = "base_urls"
        case expiresAt = "expires_at"
        case extendSeconds = "retry_interval"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventBlacklist = try container.decode(Set<String>.self, forKey: .eventBlacklist)
        baseUrls = try container.decode([AdaptyServerCluster: [URL]].self, forKey: .baseUrls)
        expiresAt = try Date(timeIntervalSince1970: (container.decode(Double.self, forKey: .expiresAt)) / 1000.0)
        extendSeconds = try container.decode(Double.self, forKey: .extendSeconds) / 1000.0
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventBlacklist, forKey: .eventBlacklist)
        try container.encode(baseUrls, forKey: .baseUrls)
        try container.encode(expiresAt.timeIntervalSince1970 * 1000.0, forKey: .expiresAt)
        try container.encode(extendSeconds * 1000.0, forKey: .extendSeconds)
    }
}
