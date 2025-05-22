//
//  Event.Packed.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

extension Event {
    struct Packed: Sendable {
        let name: String
        let id: String
        let counter: Int
        let data: Data
    }
}

extension Event.Packed {
    init(from unpacked: Event.Unpacked, counter: Int) throws {
        try self.init(
            name: unpacked.event.name,
            id: unpacked.id,
            counter: counter,
            data: Event.encoder.encode(Event.Unpacked_w_counter(original: unpacked, counter: counter))
        )
    }
}

extension Event {
    enum CodingKeys: String, CodingKey {
        case name = "event_name"
        case id = "event_id"
        case profileId = "profile_id"
        case counter
        case sessionId = "session_id"
        case createdAt = "created_at"
        case appInstallId = "device_id"
        case sysName = "platform"
        case customData = "custom_data"
    }
}

private extension Event {
    struct Unpacked_w_counter: Encodable {
        let original: Unpacked
        let counter: Int

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Event.CodingKeys.self)
            try container.encode(original.id, forKey: .id)
            try container.encode(original.profileId, forKey: .profileId)
            try container.encode(original.environment.sessionIdentifier, forKey: .sessionId)
            try container.encode(original.createdAt, forKey: .createdAt)
            try container.encode(counter, forKey: .counter)
            try container.encode(original.environment.system.name, forKey: .sysName)
            try container.encode(original.environment.application.installationIdentifier, forKey: .appInstallId)
            try container.encode(original.event.name, forKey: .name)

            try original.event.encode(to: encoder)
        }
    }
}

extension Event.Packed: Decodable {
    private static let emptyData = Data()
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Event.CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        id = try container.decode(String.self, forKey: .id)
        counter = try container.decode(Int.self, forKey: .counter)
        data = Self.emptyData
    }

    init(from data: Data) throws {
        let packed = try Event.decoder.decode(Event.Packed.self, from: data)

        self.init(
            name: packed.name,
            id: packed.id,
            counter: packed.counter,
            data: data
        )
    }
}
