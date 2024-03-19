//
//  Event.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

struct Event {
    let type: EventType
    let id: String
    let profileId: String
    let sessionId: String
    var counter: Int
    let createdAt: Date

    init(type: EventType, profileId: String) {
        self.type = type
        self.profileId = profileId
        counter = 0
        id = UUID().uuidString.lowercased()
        sessionId = Environment.Application.sessionIdentifier
        createdAt = Date()
    }
}

extension Event {
    var lowPriority: Bool {
        switch type {
        case .system: true
        default: false
        }
    }
}

extension Event: Encodable {
    enum CodingKeys: String, CodingKey {
        case type = "event_name"
        case id = "event_id"
        case profileId = "profile_id"
        case counter
        case sessionId = "session_id"
        case createdAt = "created_at"
        case appInstallId = "device_id"
        case sysName = "platform"
        case customData = "custom_data"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(profileId, forKey: .profileId)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(counter, forKey: .counter)
        try container.encode(Environment.System.name, forKey: .sysName)
        try container.encode(Environment.Application.installationIdentifier, forKey: .appInstallId)
        try type.encode(to: encoder)
    }
}

extension Event {
    fileprivate enum Default {
        static var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            return formatter
        }()

        static var encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(dateFormatter)
            encoder.dataEncodingStrategy = .base64
            return encoder
        }()

        static var decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            decoder.dataDecodingStrategy = .base64
            return decoder
        }()
    }

    func encodeToData() throws -> Data { try Default.encoder.encode(self) }

    struct Info: Decodable {
        static let emptyData = Data()
        let type: String
        let id: String
        let counter: Int
        var data: Data

        init(from event: Event) throws {
            type = event.type.name
            id = event.id
            counter = event.counter
            data = try event.encodeToData()
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Event.CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)
            id = try container.decode(String.self, forKey: .id)
            counter = try container.decode(Int.self, forKey: .counter)
            data = Info.emptyData
        }
    }

    static func decodeFromData(_ data: Data) throws -> Info {
        var info = try Default.decoder.decode(Info.self, from: data)
        info.data = data
        return info
    }
}
