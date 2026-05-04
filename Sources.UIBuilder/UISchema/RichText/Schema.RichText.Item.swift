//
//  Schema.RichText.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 09.01.2026.
//

import Foundation

extension Schema.RichText {
    typealias Item = VC.RichText.Item
}

extension Schema.RichText.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case text
        case tag
        case image
        case attributes
        case action
        case converter
        case format
    }

    init(from decoder: Decoder) throws {
        if let value = try? (try? decoder.singleValueContainer())?.decode(String.self) {
            self = .text(value, nil, nil)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.text) {
            self = try .text(
                container.decode(String.self, forKey: .text),
                container.decodeIfPresent(Schema.RichText.Attributes.self, forKey: .attributes),
                container.decodeIfPresent(Schema.Action.self, forKey: .action)
            )
        } else if container.contains(.tag) {
            var tag = try container.decode(String.self, forKey: .tag)

            let converter: Schema.AnyConverter?

            if container.exist(.converter) {
                converter = try Schema.AnyConverter.forTag(from: decoder)
            } else if tag == "PERCENT", container.exist(.format) {
                converter = try? Schema.PercentConverter(from: decoder).asAnyConverter
            } else if tag.hasPrefix("TIMER_") {
                converter = Self.legacyConverterFromTimer(tag: tag)?.asAnyConverter
                if let converter {
                    tag = "TIMER"
                }
            } else {
                converter = nil
            }

            self = try .tag(
                tag,
                container.decodeIfPresent(Schema.RichText.Attributes.self, forKey: .attributes),
                converter,
                container.decodeIfPresent(Schema.Action.self, forKey: .action)
            )
        } else if container.contains(.image) {
            self = try .image(
                container.decode(Schema.AssetReference.self, forKey: .image),
                container.decodeIfPresent(Schema.RichText.Attributes.self, forKey: .attributes)
            )
        } else {
            self = .unknown
        }
    }
}

extension Schema.RichText.Item {
    static func legacyConverterFromTimer(tag value: String) -> Schema.TimerConverter? {
        return switch value {
        case "TIMER_h": .hours("%.1d")
        case "TIMER_hh": .hours("%.2d")
        case "TIMER_m": .minutes("%.1d")
        case "TIMER_mm": .minutes("%.2d")
        case "TIMER_s": .seconds("%.1d")
        case "TIMER_ss": .seconds("%.2d")
        case "TIMER_S": .deciseconds
        case "TIMER_SS": .centiseconds
        case "TIMER_SSS": .milliseconds
        default:
            totalToConverter(tag: value, prefix: "TIMER_Total_Days_", makeConverter: Schema.TimerConverter.totalDays)
                ?? totalToConverter(tag: value, prefix: "TIMER_Total_Hours_", makeConverter: Schema.TimerConverter.totalHours)
                ?? totalToConverter(tag: value, prefix: "TIMER_Total_Minutes_", makeConverter: Schema.TimerConverter.totalMinutes)
                ?? totalToConverter(tag: value, prefix: "TIMER_Total_Seconds_", makeConverter: Schema.TimerConverter.totalSeconds)
                ?? totalToConverter(tag: value, prefix: "TIMER_Total_Milliseconds_", makeConverter: Schema.TimerConverter.totalMilliseconds)
        }

        func totalToConverter(
            tag value: String,
            prefix: String,
            makeConverter: (String) -> Schema.TimerConverter
        ) -> Schema.TimerConverter? {
            guard value.hasPrefix(prefix) else { return nil }

            let precision = Int(value.dropFirst(prefix.count)) ?? 0
            return makeConverter("%.\(precision)d")
        }
    }
}

