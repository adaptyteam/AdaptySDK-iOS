//
//  Event.Unpacked.swift
//  Adapty
//
//  Created by Aleksei Valiano on 15.09.2024
//

import Foundation

extension Event {
    struct Unpacked: Sendable {
        let id: String
        let event: Event
        let profileId: String
        let environment: Environment
        let createdAt: Date
    }
}

extension EventsManager {
    @AdaptyActor
    func trackEvent(_ event: Event, profileId: String, createdAt: Date = Date()) async throws {
        try await self.trackEvent(.init(
            id: UUID().uuidString.lowercased(),
            event: event,
            profileId: profileId,
            environment: Environment.instance,
            createdAt: createdAt
        ))
    }
}
