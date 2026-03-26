//
//  Schema.Timer.State.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension Schema {
    private enum CodingKeys: String, CodingKey {
        case duration
        case behavior = "behaviour"
        case endTime = "end_time"
    }

    private enum BehaviorType: String, Codable {
        case everyAppear = "start_at_every_appear"
        case firstAppear = "start_at_first_appear"
        case firstAppearPersisted = "start_at_first_appear_persisted"
        case endAtLocalTime = "end_at_local_time"
        case endAtUTC = "end_at_utc_time"
        case custom
    }

    static func decodeLegacySetTimer(id: String, from decoder: Decoder) throws -> String {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        var endAt: Date?
        var duration: TimeInterval?
        var behavior: VC.SetTimerBehavior?

        let value = try container.decodeIfPresent(String.self, forKey: .behavior)

        switch value {
        case BehaviorType.endAtUTC.rawValue:
            endAt = try container.decodeLegacyEndTimeString(forKey: .endTime, in: TimeZone(identifier: "UTC"))
        case BehaviorType.endAtLocalTime.rawValue:
            endAt = try container.decodeLegacyEndTimeString(forKey: .endTime, in: .current)
        case nil:
            duration = try container.decode(TimeInterval.self, forKey: .duration)
            behavior = .continue
        case BehaviorType.everyAppear.rawValue:
            duration = try container.decode(TimeInterval.self, forKey: .duration)
            behavior = .restart
        case BehaviorType.firstAppear.rawValue:
            duration = try container.decode(TimeInterval.self, forKey: .duration)
            behavior = .continue
        case BehaviorType.firstAppearPersisted.rawValue:
            duration = try container.decode(TimeInterval.self, forKey: .duration)
            behavior = .persisted
        case BehaviorType.custom.rawValue:
            duration = try container.decode(TimeInterval.self, forKey: .duration)
            behavior = .custom
        default:
            throw DecodingError.dataCorruptedError(forKey: .behavior, in: container, debugDescription: "unknown value '\(value ?? "nil")'")
        }

        return if let endAt {
            #"SDK.setTimer({"id":"\#(id)", "endAt": \#(endAt.timeIntervalSince1970 * 1000.0)});"#
        } else if let duration {
            #"SDK.setTimer({"id":"\#(id)", "duration": \#(duration), "behavior": "\#((behavior ?? .continue).rawValue)"});"#
        } else {
            throw DecodingError.dataCorruptedError(forKey: .behavior, in: container, debugDescription: "unknown value '\(value ?? "nil")'")
        }
    }
}

