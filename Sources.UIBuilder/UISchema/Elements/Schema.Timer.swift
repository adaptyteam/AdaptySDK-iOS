//
//  Schema.Timer.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

extension Schema {
    struct Timer: Sendable, Hashable {
        let id: String
        let state: State
        let format: [Item]
        let actions: [Schema.Action]
        let horizontalAlign: HorizontalAlignment
        let defaultTextAttributes: Text.Attributes?

        struct Item: Sendable, Hashable {
            let from: TimeInterval
            let stringId: String
        }
    }
}

extension VC.Timer.StartBehavior {
    static let `default` = Self.firstAppear
}

extension Schema.Localizer {
    func convertTimer(_ from: Schema.Timer) -> VC.Timer {
        .init(
            id: from.id,
            state: from.state,
            format: .init(
                items: from.format.compactMap {
                    guard let value = strings[$0.stringId] else { return nil }

                    return .init(
                        from: $0.from,
                        value: value
                    )
                },
                textAttributes: from.defaultTextAttributes
            ),

            actions: from.actions,
            horizontalAlign: from.horizontalAlign
        )
    }
}

extension Schema.Timer: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case duration
        case behavior = "behaviour"
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
                try .endedAt(container.decode(Schema.DateString.self, forKey: .endTime).utc)
            case BehaviorType.endAtLocalTime.rawValue:
                try .endedAt(container.decode(Schema.DateString.self, forKey: .endTime).local)
            case nil:
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
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.behavior], debugDescription: "unknown value '\(behavior ?? "nil")'"))
            }

        format =
            if let stringId = try? container.decode(String.self, forKey: .format) {
                [.init(from: 0, stringId: stringId)]
            } else {
                try container.decode([Item].self, forKey: .format)
            }

        actions = try container.decodeIfPresentActions(forKey: .actions) ?? []

        horizontalAlign = try container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading
        let textAttributes = try Schema.Text.Attributes(from: decoder)
        defaultTextAttributes = textAttributes.nonEmptyOrNil
    }
}

extension Schema {
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

extension Schema.Timer.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case from
        case stringId = "string_id"
    }
}
