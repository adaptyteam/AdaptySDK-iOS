//
//  Schema.EventHandler.Trigger.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 06.04.2026.
//

extension Schema.EventHandler.Trigger {
    @inlinable
    var isEmpty: Bool {
        events.isEmpty
    }
}

extension Schema.EventHandler.Trigger: Codable {
    enum CodingKeys: String, CodingKey {
        case events
        case filter
        case screenTransitions = "transitions"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let events = try container.decode([Schema.EventHandler.EventId].self, forKey: .events)
        if !events.isEmpty {
            try self.init(
                events: events,
                filter: container.decodeIfPresent(Schema.EventHandler.Filter.self, forKey: .filter),
                screenTransitions: container.decodeIfPresent([String].self, forKey: .screenTransitions)
            )
        } else {
            self.init(
                events: [],
                filter: nil,
                screenTransitions: nil
            )
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(events, forKey: .events)
        try container.encodeIfPresent(filter, forKey: .filter)
        try container.encodeIfPresent(screenTransitions, forKey: .screenTransitions)
    }
}

