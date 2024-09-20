//
//  AdaptyLog.Record+Codable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.08.2024
//

import Foundation

extension AdaptyLog.Record: Codable {
    enum CodingKeys: String, CodingKey {
        case date
        case level
        case message
        case category
        case source = "debug_info"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try Date(timeIntervalSince1970: container.decode(Double.self, forKey: .date) / 1000.0)
        level = try container.decode(Log.Level.self, forKey: .level)
        message = try container.decode(String.self, forKey: .message)
        category = try container.decode(Log.Category.self, forKey: .category)
        source = try container.decode(Log.Source.self, forKey: .source)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Int64(date.timeIntervalSince1970 * 1000), forKey: .date)
        try container.encode(level, forKey: .level)
        try container.encode(message, forKey: .message)
        try container.encode(category, forKey: .category)
        try container.encode(source, forKey: .source)
    }
}
