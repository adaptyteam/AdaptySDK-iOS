//
//  NetworkConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.10.2025.
//

import Foundation

struct NetworkConfiguration: Sendable {
    fileprivate static let basePath = "/api/v1"

    static var defaultState: NetworkState {
        .init(
            eventBlacklist: Event.defaultBlackList,
            baseUrls: [
                .default: [URL(string: "https://api.adapty.io\(basePath)")!],
                .eu: [URL(string: "https://api-eu.adapty.io\(basePath)")!],
                .cn: [URL(string: "https://api-cn.adapty.io\(basePath)")!]
            ],
            expiresAt: Date(timeIntervalSince1970: 0),
            extendSeconds: 1800
        )
    }

    static func fallbackBaseUrl(by cluster: AdaptyServerCluster) -> URL {
        switch cluster {
        case .cn:
            URL(string: "https://fallback-cn.adapty.io\(basePath)")!
        default:
            URL(string: "https://fallback.adapty.io\(basePath)")!
        }
    }

    static func configsBaseUrl(by cluster: AdaptyServerCluster) -> URL {
        switch cluster {
        case .cn:
            URL(string: "https://configs-cdn-cn.adapty.io\(basePath)")!
        default:
            URL(string: "https://configs-cdn.adapty.io\(basePath)")!
        }
    }

    static func uaBaseUrl(by cluster: AdaptyServerCluster) -> URL {
        switch cluster {
        case .cn:
            URL(string: "https://api-ua-cn.adapty.io\(basePath)")!
        default:
            URL(string: "https://api-ua.adapty.io\(basePath)")!
        }
    }

    static func networkConfigurationBaseUrl(by cluster: AdaptyServerCluster) -> URL {
        fallbackBaseUrl(by: cluster)
    }

    let eventBlacklist: Set<String>
    let baseUrls: [AdaptyServerCluster: [URL]]
    let expiresIn: TimeInterval
    let extendSeconds: TimeInterval
}

extension URL {
    var appendingDefaultPathIfNeed: Self {
        guard path.isEmpty || path == "/" else { return self }
        return appendingPathComponent(NetworkConfiguration.basePath)
    }
}

extension NetworkConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case eventBlacklist = "event_blacklist"
        case baseUrls = "api_endpoints"
        case expiresIn = "expires_in"
        case extendSeconds = "retry_interval"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.eventBlacklist = try container.decode(Set<String>.self, forKey: .eventBlacklist)
        self.baseUrls = try container.decode([AdaptyServerCluster: [URL]].self, forKey: .baseUrls)
        self.expiresIn = try container.decode(Double.self, forKey: .expiresIn) / 1000.0
        self.extendSeconds = try container.decode(Double.self, forKey: .extendSeconds) / 1000.0
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventBlacklist, forKey: .eventBlacklist)
        try container.encode(baseUrls, forKey: .baseUrls)
        try container.encode(Int64(expiresIn * 1000), forKey: .expiresIn)
        try container.encode(Int64(extendSeconds * 1000), forKey: .extendSeconds)
    }
}
