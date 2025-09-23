//
//  Category+Codable.swift
//  AdaptyLogger
//
//  Created by Aleksei Valiano on 24.08.2024
//

import Foundation

extension AdaptyLogger.Category: Codable {
    enum CodingKeys: String, CodingKey {
        case subsystem
        case version
        case name
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        subsystem = try container.decode(String.self, forKey: .subsystem)
        version = try container.decode(String.self, forKey: .version)
        name = try container.decode(String.self, forKey: .name)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(subsystem, forKey: .subsystem)
        try container.encode(version, forKey: .version)
        try container.encode(name, forKey: .name)
    }
}
