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
        let userId: AdaptyUserId
        let environment: Environment
        let createdAt: Date

        init(
            id: String = UUID().uuidString.lowercased(),
            event: Event,
            userId: AdaptyUserId,
            environment: Environment,
            createdAt: Date = Date()
        ) {
            self.id = id
            self.event = event
            self.userId = userId
            self.environment = environment
            self.createdAt = createdAt
        }
    }
}
