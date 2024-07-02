//
//  VC.Timer.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyUI.ViewConfiguration {
    struct Timer: Hashable, Sendable {
        let id: String
        let state: AdaptyUI.Timer.State
        let format: [Item]
        let actions: [AdaptyUI.ViewConfiguration.Action]
        let horizontalAlign: AdaptyUI.HorizontalAlignment
        let defaultTextAttributes: TextAttributes?

        struct Item: Hashable, Sendable {
            let from: TimeInterval
            let stringId: String
        }
    }
}

extension AdaptyUI.ViewConfiguration.Localizer {
    func timer(_ from: AdaptyUI.ViewConfiguration.Timer) throws -> AdaptyUI.Timer {
        try .init(
            id: from.id,
            state: from.state,
            format: from.format.compactMap {
                guard let value = richText(
                    stringId: $0.stringId,
                    defaultTextAttributes: from.defaultTextAttributes
                ) else { return nil }

                return AdaptyUI.Timer.Item(
                    from: $0.from,
                    value: value
                )
            },
            actions: from.actions.map(action),
            horizontalAlign: from.horizontalAlign
        )
    }
}

extension AdaptyUI.ViewConfiguration.Timer: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case duration
        case behaviour
        case format
        case endTime = "end_time"
        case actions = "action"
        case horizontalAlign = "align"
    }

    enum BehaviourType: String, Codable {
        case everyAppear = "start_at_every_appear"
        case firstAppear = "start_at_first_appear"
        case firstAppearPersisted = "start_at_first_appear_persisted"
        case endAtLocalTime = "end_at_local_time"
        case endAtUTC = "end_at_utc_time"
        case custom
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)

        let behaviour = try container.decodeIfPresent(String.self, forKey: .behaviour)

        state =
            switch behaviour {
            case BehaviourType.endAtUTC.rawValue:
                try .endedAt(container.decode(AdaptyUI.ViewConfiguration.DateString.self, forKey: .endTime).utc)
            case BehaviourType.endAtLocalTime.rawValue:
                try .endedAt(container.decode(AdaptyUI.ViewConfiguration.DateString.self, forKey: .endTime).local)
            case .none:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .default)
            case BehaviourType.everyAppear.rawValue:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .everyAppear)
            case BehaviourType.firstAppear.rawValue:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .firstAppear)
            case BehaviourType.firstAppearPersisted.rawValue:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .firstAppearPersisted)
            case BehaviourType.custom.rawValue:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .custom)
            default:
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.behaviour], debugDescription: "unknown value '\(behaviour ?? "null")'"))
            }

        format =
            if let stringId = try? container.decode(String.self, forKey: .format) {
                [.init(from: 0, stringId: stringId)]
            } else {
                try container.decode([Item].self, forKey: .format)
            }

        actions =
            if let action = try? container.decodeIfPresent(AdaptyUI.ViewConfiguration.Action.self, forKey: .actions) {
                [action]
            } else {
                try container.decodeIfPresent([AdaptyUI.ViewConfiguration.Action].self, forKey: .actions) ?? []
            }

        horizontalAlign = try container.decodeIfPresent(AdaptyUI.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading
        let textAttributes = try AdaptyUI.ViewConfiguration.TextAttributes(from: decoder)
        defaultTextAttributes = textAttributes.isEmpty ? nil : textAttributes
    }
}

extension AdaptyUI.ViewConfiguration {
    struct DateString: Decodable {
        let utc: Date
        let local: Date

        init(from decoder: any Decoder) throws {
            let value = try decoder.singleValueContainer().decode(String.self)
            let arrayString = value.components(separatedBy: CharacterSet(charactersIn: " -:.,;/\\"))
            let array = try arrayString.map {
                guard let value = Int($0) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "wrong date format  '\(value)'"))
                }
                return value
            }
            guard array.count >= 6 else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "wrong date format  '\(value)'"))
            }

            var components = DateComponents(
                calendar: Calendar(identifier: .gregorian),
                year: array[0],
                month: array[1],
                day: array[2],
                hour: array[3],
                minute: array[4],
                second: array[5]
            )
            var utcComponents = components

            utcComponents.timeZone = TimeZone(identifier: "UTC")
            components.timeZone = TimeZone.current

            guard let utc = utcComponents.date, let local = components.date else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "wrong date '\(value)'"))
            }

            self.local = local
            self.utc = utc
        }
    }
}

extension AdaptyUI.ViewConfiguration.Timer.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case from
        case stringId = "string_id"
    }
}
