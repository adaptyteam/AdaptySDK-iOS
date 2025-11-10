//
//  EventsBackendConfiguration.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2022.
//

import Foundation

struct EventsBackendConfiguration: Sendable {
    var blacklist: Set<String>
    let expiresAt: Date

    init(_ state: NetworkState) {
        blacklist = state.eventBlacklist
        expiresAt = state.expiresAt
    }

    init() {
        blacklist = Set<String>()
        expiresAt = Date(timeIntervalSince1970: 0)
    }
}

extension EventsBackendConfiguration {
    var isExpired: Bool {
        expiresAt <= Date()
    }
}
