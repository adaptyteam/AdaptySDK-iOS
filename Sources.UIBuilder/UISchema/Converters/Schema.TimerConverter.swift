//
//  Schema.TimerConverter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.04.2026.
//

import Foundation

extension Schema {
    typealias TimerConverter = VC.TimerConverter
}

extension Schema.TimerConverter: Decodable {
    private enum CodingKeys: String, CodingKey {
        case converter
        case format
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKeys: .converter)
        let format = try container.decodeIfPresent(String.self, forKeys: .format)

        if let format {
            guard format.isValidIntegerFormat else {
                throw DecodingError.dataCorruptedError(forKey: .format, in: container, debugDescription: "wrong format: \(format)")
            }
        }

        switch name {
        case "days":
            self = .days(format ?? "%01d")
        case "hours":
            self = .hours(format ?? "%01d")
        case "minutes":
            self = .minutes(format ?? "%01d")
        case "seconds":
            self = .seconds(format ?? "%01d")
        case "deciseconds":
            self = .deciseconds
        case "centiseconds":
            self = .centiseconds
        case "milliseconds":
            self = .milliseconds
        case "total_days":
            self = .totalDays(format ?? "%d")
        case "total_hours":
            self = .totalHours(format ?? "%d")
        case "total_minutes":
            self = .totalMinutes(format ?? "%d")
        case "total_seconds":
            self = .totalSeconds(format ?? "%d")
        case "total_milliseconds":
            self = .totalMilliseconds(format ?? "%d")
        default:
            throw DecodingError.dataCorruptedError(forKey: .converter, in: container, debugDescription: " Unknown converter \(name)")
        }
    }
}


