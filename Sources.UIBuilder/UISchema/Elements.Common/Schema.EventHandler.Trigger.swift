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

extension Schema.EventHandler.Trigger: Decodable {
    enum CodingKeys: String, CodingKey {
        case events
        case filter
        case screenTransitions = "transitions"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let events = try container.decode([Schema.EventHandler.EventId].self, forKey: .events)

        guard !events.isEmpty else {
            self.init(
                events: [],
                filter: nil,
                screenTransitions: nil
            )
            return
        }

        try self.init(
            events: events,
            filter: container.decodeIfPresent(Schema.EventHandler.Filter.self, forKey: .filter),
            screenTransitions: container.decodeIfPresent([String].self, forKey: .screenTransitions)
        )
    }
}

