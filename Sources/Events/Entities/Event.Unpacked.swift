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
        let sessionId: String
        let createdAt: Date

        init(from event: Event, _ profileId: String) {
            self.id = UUID().uuidString.lowercased()
            self.event = event
            self.profileId = profileId
            sessionId = Environment.Application.sessionIdentifier
            createdAt = Date()
        }
    }
}
