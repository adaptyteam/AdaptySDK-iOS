//
//  EventsBackendConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

struct EventsBackendConfiguration: Equatable {
    var blacklist: Set<String>
    let expiration: Date

    init(blacklist: Set<String>, expiration: Date) {
        self.blacklist = blacklist
        self.expiration = expiration
    }

    init() {
        blacklist = Set<String>()
        expiration = Date(timeIntervalSince1970: 0)
    }
}

extension EventsBackendConfiguration {
    var isExpired: Bool {
        expiration <= Date()
    }
}

extension EventsBackendConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case blacklist
        case expiration = "expires_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        blacklist = try Set(container.decode([String].self, forKey: .blacklist))
        expiration = try Date(timeIntervalSince1970: (container.decode(Double.self, forKey: .expiration)) / 1000.0)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Array(blacklist), forKey: .blacklist)
        try container.encode(expiration.timeIntervalSince1970 * 1000.0, forKey: .expiration)
    }
}
