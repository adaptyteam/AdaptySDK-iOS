//
//  VC.Timer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension AdaptyViewSource {
    struct Timer: Sendable, Hashable {
        let id: String
        let state: AdaptyViewConfiguration.Timer.State
        let format: [Item]
        let actions: [AdaptyViewSource.Action]
        let horizontalAlign: AdaptyViewConfiguration.HorizontalAlignment
        let defaultTextAttributes: TextAttributes?

        struct Item: Sendable, Hashable {
            let from: TimeInterval
            let stringId: String
        }
    }
}

extension AdaptyViewSource.Localizer {
    func timer(_ from: AdaptyViewSource.Timer) throws -> AdaptyViewConfiguration.Timer {
        try .init(
            id: from.id,
            state: from.state,
            format: from.format.compactMap {
                guard let value = richText(
                    stringId: $0.stringId,
                    defaultTextAttributes: from.defaultTextAttributes
                ) else { return nil }

                return AdaptyViewConfiguration.Timer.Item(
                    from: $0.from,
                    value: value
                )
            },
            actions: from.actions.map(action),
            horizontalAlign: from.horizontalAlign
        )
    }
}

extension AdaptyViewSource.Timer: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case duration
        case behavior
        case format
        case endTime = "end_time"
        case actions = "action"
        case horizontalAlign = "align"
    }

    enum BehaviorType: String, Codable {
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

        let behavior = try container.decodeIfPresent(String.self, forKey: .behavior)

        state =
            switch behavior {
            case BehaviorType.endAtUTC.rawValue:
                try .endedAt(container.decode(AdaptyViewSource.DateString.self, forKey: .endTime).utc)
            case BehaviorType.endAtLocalTime.rawValue:
                try .endedAt(container.decode(AdaptyViewSource.DateString.self, forKey: .endTime).local)
            case .none:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .default)
            case BehaviorType.everyAppear.rawValue:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .everyAppear)
            case BehaviorType.firstAppear.rawValue:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .firstAppear)
            case BehaviorType.firstAppearPersisted.rawValue:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .firstAppearPersisted)
            case BehaviorType.custom.rawValue:
                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .custom)
            default:
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.behavior], debugDescription: "unknown value '\(behavior ?? "null")'"))
            }

        format =
            if let stringId = try? container.decode(String.self, forKey: .format) {
                [.init(from: 0, stringId: stringId)]
            } else {
                try container.decode([Item].self, forKey: .format)
            }

        actions =
            if let action = try? container.decodeIfPresent(AdaptyViewSource.Action.self, forKey: .actions) {
                [action]
            } else {
                try container.decodeIfPresent([AdaptyViewSource.Action].self, forKey: .actions) ?? []
            }

        horizontalAlign = try container.decodeIfPresent(AdaptyViewConfiguration.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading
        let textAttributes = try AdaptyViewSource.TextAttributes(from: decoder)
        defaultTextAttributes = textAttributes.isEmpty ? nil : textAttributes
    }
}

extension AdaptyViewSource {
    struct DateString: Decodable {
        let utc: Date
        let local: Date

        init(from decoder: Decoder) throws {
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

extension AdaptyViewSource.Timer.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case from
        case stringId = "string_id"
    }
}
