//
//  NetworkState.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

struct BackendState: Sendable {
    let eventBlacklist: Set<String>
    let mainBaseUrls: [AdaptyServerCluster: [URL]]
    let expiresAt: Date
    let extendSeconds: TimeInterval
}

extension BackendState {
    static func createDefault() -> Self {
        .init(
            eventBlacklist: Event.defaultBlackList,
            mainBaseUrls: [
                .default: [Backend.defaultBaseUrl(kind: .main, by: .default)],
                .eu: [Backend.defaultBaseUrl(kind: .main, by: .eu)],
                .cn: [Backend.defaultBaseUrl(kind: .main, by: .cn)]
            ],
            expiresAt: Date(timeIntervalSince1970: 0),
            extendSeconds: 1800
        )
    }

    func extended(now: Date = Date()) -> Self {
        .init(
            eventBlacklist: eventBlacklist,
            mainBaseUrls: mainBaseUrls,
            expiresAt: now.addingTimeInterval(extendSeconds),
            extendSeconds: extendSeconds
        )
    }

    var isExpired: Bool {
        expiresAt <= Date()
    }

    func mainBaseUrl(by cluster: AdaptyServerCluster, withIndex index: Int) -> URL? {
        var baseUrls = mainBaseUrls[cluster]
        if baseUrls == nil, cluster != .default {
            baseUrls = mainBaseUrls[.default]
        }
        guard let baseUrls, baseUrls.isNotEmpty else { return nil }
        return baseUrls[min(index, baseUrls.endIndex)].appendingDefaultPathIfNeed
    }
}

extension BackendState: Codable {
    enum CodingKeys: String, CodingKey {
        case eventBlacklist = "event_blacklist"
        case mainBaseUrls = "api_endpoints"
        case expiresAt = "expires_at"
        case expiresIn = "expires_in"
        case extendSeconds = "retry_interval"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventBlacklist = try container.decode(Set<String>.self, forKey: .eventBlacklist)
        mainBaseUrls = try container.decode([AdaptyServerCluster: [URL]].self, forKey: .mainBaseUrls)
        if container.contains(.expiresAt) {
            expiresAt = try Date(timeIntervalSince1970: (container.decode(Double.self, forKey: .expiresAt)) / 1000.0)
        } else {
            let expiresIn = try container.decode(Double.self, forKey: .expiresIn) / 1000.0
            expiresAt = Date().addingTimeInterval(expiresIn)
        }
        extendSeconds = try container.decode(Double.self, forKey: .extendSeconds) / 1000.0
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventBlacklist, forKey: .eventBlacklist)
        try container.encode(mainBaseUrls, forKey: .mainBaseUrls)
        try container.encode(expiresAt.timeIntervalSince1970 * 1000.0, forKey: .expiresAt)
        try container.encode(extendSeconds * 1000.0, forKey: .extendSeconds)
    }
}
