//
//  Event.Unpacked.swift
//  AdaptySDK
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

        init(
            id: String = UUID().uuidString.lowercased(),
            event: Event,
            profileId: String,
            environment: Environment,
            createdAt: Date = Date()
        ) {
            self.id = id
            self.event = event
            self.profileId = profileId
            self.environment = environment
            self.createdAt = createdAt
        }
    }
}
