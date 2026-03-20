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
        let format: Schema.RangeTextFormat
        let actions: [Schema.Action]
        let horizontalAlign: HorizontalAlignment
    }
}

extension VC.Timer.StartBehavior {
    static let `default` = Self.firstAppear
}

extension Schema.ConfigurationBuilder {
    @inlinable
    func convertTimer(_ from: Schema.Timer) -> VC.Timer {
        .init(
            id: from.id,
            state: from.state,
            format: convertRangeTextFormat(from.format),
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
        case endAt = "end_at_time"
        case legacyEndAtLocalTime = "end_at_local_time"
        case legacyEndAtUTC = "end_at_utc_time"
        case custom
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)

        let behavior = try container.decodeIfPresent(String.self, forKey: .behavior)

        state =
            switch behavior {
            case BehaviorType.legacyEndAtUTC.rawValue:
                try .endedAt(container.decodeLegacyEndTimeString(forKey: .endTime, in: TimeZone(identifier: "UTC")))
            case BehaviorType.legacyEndAtLocalTime.rawValue:
                try .endedAt(container.decodeLegacyEndTimeString(forKey: .endTime, in: .current))
            case BehaviorType.endAt.rawValue:
                try .endedAt(container.decodeDateTime(forKey: .endTime))
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

        let formatItems =
            if let stringId = try? container.decode(String.self, forKey: .format) {
                [Schema.RangeTextFormat.Item(from: 0, stringId: stringId)]
            } else {
                try container.decode([Schema.RangeTextFormat.Item].self, forKey: .format)
            }

        format = try Schema.RangeTextFormat(
            items: formatItems,
            textAttributes: Schema.TextAttributes(from: decoder)
        )

        actions = try container.decodeIfPresentActions(forKey: .actions) ?? []

        horizontalAlign = try container.decodeIfPresent(Schema.HorizontalAlignment.self, forKey: .horizontalAlign) ?? .leading
    }
}
