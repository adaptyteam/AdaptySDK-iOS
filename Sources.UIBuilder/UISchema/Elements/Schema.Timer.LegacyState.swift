//
//  Schema.Timer.State.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension Schema.Timer {
    enum LegacyState: Sendable, Hashable {
        case endedAt(VC.DateTime)
        case duration(TimeInterval, start: LegacyStartBehavior)
    }
}

extension Schema.Timer {
    enum LegacyStartBehavior:  Sendable, Hashable {
        static let `default` = Self.firstAppear

        case everyAppear
        case firstAppear
        case firstAppearPersisted
        case custom
    }
}

// SDK.setTimer id endAt: unixtimestamp
// SDK.setTimer id  duration: seconds behavior: [ restart continue pesisted custom ] VC.SetTimerBehavior
//
//extension Schema.Timer.LegacyState: Decodable {
//    enum CodingKeys: String, CodingKey {
//        case duration
//        case behavior = "behaviour"
//        case endTime = "end_time"
//    }
//
//    enum BehaviorType: String, Codable {
//        case everyAppear = "start_at_every_appear"
//        case firstAppear = "start_at_first_appear"
//        case firstAppearPersisted = "start_at_first_appear_persisted"
//        case endAtLocalTime = "end_at_local_time"
//        case endAtUTC = "end_at_utc_time"
//        case custom
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        let behavior = try container.decodeIfPresent(String.self, forKey: .behavior)
//
//
//        let action: Schema.Action  =
//            switch behavior {
//            case BehaviorType.endAtUTC.rawValue:
//
//                let date
//                try .date(container.decodeLegacyEndTimeString(forKey: .endTime, in: TimeZone(identifier: "UTC")))
//            case BehaviorType.endAtLocalTime.rawValue:
//                try .endedAt(.date(container.decodeLegacyEndTimeString(forKey: .endTime, in: .current)))
//
//            case nil:
//                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .default)
//            case BehaviorType.everyAppear.rawValue:
//                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .everyAppear)
//            case BehaviorType.firstAppear.rawValue:
//                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .firstAppear)
//            case BehaviorType.firstAppearPersisted.rawValue:
//                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .firstAppearPersisted)
//            case BehaviorType.custom.rawValue:
//                try .duration(container.decode(TimeInterval.self, forKey: .duration), start: .custom)
//            default:
//                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.behavior], debugDescription: "unknown value '\(behavior ?? "nil")'"))
//            }
//    }
//}
//
