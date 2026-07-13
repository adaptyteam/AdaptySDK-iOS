//
//  Schema.DateTimePicker.Components.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension Schema.DateTimePicker.Components: Decodable {
    private enum CodingKeys: String, Codable {
        case date
        case hourAndMinute = "hour_and_minute"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        let keys = try container.decode([CodingKeys].self)
        var components = Self()
        for key in keys {
            switch key {
            case .date: components.insert(.date)
            case .hourAndMinute: components.insert(.hourAndMinute)
            }
        }
        self = components
    }
}
