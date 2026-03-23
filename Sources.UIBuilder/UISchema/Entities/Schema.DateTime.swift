//
//  Schema.DateTime.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

private extension Calendar {
    static let localTimeZone = {
        var cal = Calendar(identifier: .iso8601)
        cal.firstWeekday = 2
        return cal
    }()

    static func withTimeZone(_ timeZone: TimeZone?) -> Calendar {
        guard let timeZone else { return localTimeZone }
        var cal = localTimeZone
        cal.timeZone = timeZone
        return cal
    }
}

private enum DateComponentsCodingKeys: String, CodingKey {
    case timeZone = "time_zone"
    case year
    case month
    case day
    case hour
    case minute
    case second
}

private enum RelativeDateTimeCodingKeys: String, CodingKey {
    case anchor
    case anchorTimeZone = "anchor_time_zone"
    case offset
}

private enum DateTimeAnchor: String, Codable {
    case now = "start"
    case startOfDay = "start_of_day"
    case startOfWeek = "start_of_week"
    case startOfMonth = "start_of_month"
    case startOfYear = "start_of_year"

    func date(for callendar: Calendar) -> Date? {
        switch self {
        case .now:
            return Date()
        case .startOfDay:
            return callendar.startOfDay(for: Date())
        case .startOfWeek:
            var startOfWeek = Date()
            var interval: TimeInterval = 0
            guard callendar
                .dateInterval(of: .weekOfYear, start: &startOfWeek, interval: &interval, for: Date())
            else { return nil }
            return startOfWeek
        case .startOfMonth:
            let comps = callendar.dateComponents([.year, .month], from: Date())
            return callendar.date(from: comps)
        case .startOfYear:
            let comps = callendar.dateComponents([.year], from: Date())
            return callendar.date(from: comps)
        }
    }
}

extension KeyedDecodingContainer {
    func decodeDateTime(forKey key: Key) throws -> VC.DateTime {
        if let unixtimestamp = try? decode(Double.self, forKey: key) {
            return .date(Date(timeIntervalSince1970: unixtimestamp / 1000.0))
        }

        let container = try nestedContainer(keyedBy: RelativeDateTimeCodingKeys.self, forKey: key)

        if container.contains(.anchor) {
            let anchorTimeZone = try container.decodeTimeZoneIfPresent(forKey: .anchorTimeZone)
            let anchor = try container.decode(DateTimeAnchor.self, forKey: .anchor)
            let calendar = Calendar.withTimeZone(anchorTimeZone)
            guard let startDate = anchor.date(for: calendar) else {
                throw DecodingError.dataCorruptedError(forKey: .anchor, in: container, debugDescription: "Fail to calculate `\(anchor.rawValue)`")
            }

            guard container.contains(.offset) else {
                return .date(startDate)
            }

            if let value = try? container.decode(Double.self, forKey: .offset) {
                if anchor == .now {
                    return .fromStart(value / 1000.0)
                }
                return .date(startDate.addingTimeInterval(value / 1000.0))
            }

            let interval = try container.decodeIntervalComponents(forKey: .offset)

            guard let date = calendar.date(byAdding: interval, to: startDate) else {
                throw DecodingError.dataCorruptedError(forKey: .offset, in: container, debugDescription: "Invalid time interval components")
            }

            if anchor == .now {
                return .fromStart(date.timeIntervalSince(startDate))
            }
            return .date(date)
        }

        return try .date(decodeDateComponents(forKey: key))
    }

    func decodeDateTimeIfPresent(forKey key: Key) throws -> VC.DateTime? {
        guard contains(key) else { return nil }
        return try decodeDateTime(forKey: key)
    }
}

private extension KeyedDecodingContainer {
    func decodeIntervalComponents(forKey key: Key) throws -> DateComponents {
        let container = try nestedContainer(keyedBy: DateComponentsCodingKeys.self, forKey: key)
        var comps = DateComponents()
        comps.year = try container.decodeIfPresent(Int.self, forKey: .year) ?? 0
        comps.month = try container.decodeIfPresent(Int.self, forKey: .month) ?? 0
        comps.day = try container.decodeIfPresent(Int.self, forKey: .day) ?? 0
        comps.hour = try container.decodeIfPresent(Int.self, forKey: .hour) ?? 0
        comps.minute = try container.decodeIfPresent(Int.self, forKey: .minute) ?? 0
        comps.second = try container.decodeIfPresent(Int.self, forKey: .second) ?? 0
        return comps
    }
}

private extension KeyedDecodingContainer {
    func decodeDateComponents(forKey key: Key) throws -> Date {
        let container = try nestedContainer(keyedBy: DateComponentsCodingKeys.self, forKey: key)

        let timeZone = try container.decodeTimeZoneIfPresent(forKey: .timeZone)

        let year = try container.decode(Int.self, forKey: .year)
        guard year > 0 else {
            throw DecodingError.dataCorruptedError(forKey: .year, in: container, debugDescription: "must be greater than 0")
        }
        let month = try container.decode(Int.self, forKey: .month)
        guard month > 0, month <= 12 else {
            throw DecodingError.dataCorruptedError(forKey: .month, in: container, debugDescription: "must be in range 1...12")
        }
        let day = try container.decode(Int.self, forKey: .day)
        guard day > 0, day <= 31 else {
            throw DecodingError.dataCorruptedError(forKey: .month, in: container, debugDescription: "must be in range 1...31")
        }
        let hour = try container.decodeIfPresent(Int.self, forKey: .hour) ?? 0
        guard hour >= 0, hour <= 23 else {
            throw DecodingError.dataCorruptedError(forKey: .month, in: container, debugDescription: "must be in range 0...23")
        }
        let minute = try container.decodeIfPresent(Int.self, forKey: .minute) ?? 0
        guard minute >= 0, minute <= 59 else {
            throw DecodingError.dataCorruptedError(forKey: .month, in: container, debugDescription: "must be in range 0...59")
        }
        let second = try container.decodeIfPresent(Int.self, forKey: .second) ?? 0
        guard second >= 0, second <= 59 else {
            throw DecodingError.dataCorruptedError(forKey: .month, in: container, debugDescription: "must be in range 0...59")
        }

        var comps = DateComponents()
        if let timeZone {
            comps.timeZone = timeZone
        }
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = hour
        comps.minute = minute
        comps.second = second

        if let date = Calendar.localTimeZone.date(from: comps) {
            return date
        } else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Wrong date components")
        }
    }
}

private extension KeyedDecodingContainer {
    func decodeTimeZone(forKey key: Key) throws -> TimeZone {
        let value = try decode(String.self, forKey: key)

        if value == "UTC" {
            if let v = TimeZone(identifier: "UTC") {
                return v
            } else {
                throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Unsupport UTC")
            }
        }

        if value.first == "+" || value.first == "-" {
            if let v = TimeZone(identifier: "GMT\(value)") {
                return v
            } else {
                throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Unsupport GMT\(value)")
            }
        }

        if let v = TimeZone(identifier: value) {
            return v
        }

        throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Unsupport `\(value)`")
    }

    func decodeTimeZoneIfPresent(forKey key: Key) throws -> TimeZone? {
        guard contains(key) else { return nil }
        return try decodeTimeZone(forKey: key)
    }
}

