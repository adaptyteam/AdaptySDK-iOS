//
//  AdaptyLogRecord+Codable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.08.2024
//

import Foundation

extension AdaptyLogRecord: Codable {
    enum CodingKeys: String, CodingKey {
        case date
        case level
        case value
        case source = "debug_info"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try Date(timeIntervalSince1970: container.decode(Double.self, forKey: .date) / 1000.0)
        level = try container.decode(AdaptyLogLevel.self, forKey: .level)
        value = try container.decode(String.self, forKey: .value)
        source = try container.decode(AdaptyLogRecord.Source.self, forKey: .source)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Int64(date.timeIntervalSince1970 * 1000), forKey: .date)
        try container.encode(level, forKey: .level)
        try container.encode(value, forKey: .value)
        try container.encode(source, forKey: .source)
    }
}

extension AdaptyLogRecord.Source: Codable {
    enum CodingKeys: String, CodingKey {
        case sdkVersion = "sdk_version"
        case threadName = "thread"
        case fileName = "file"
        case functionName = "function"
        case lineNumber = "line"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sdkVersion = try container.decode(String.self, forKey: .sdkVersion)
        threadName = try container.decode(String.self, forKey: .threadName)
        fileName = try container.decode(String.self, forKey: .fileName)
        functionName = try container.decode(String.self, forKey: .functionName)
        lineNumber = try container.decode(UInt.self, forKey: .lineNumber)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sdkVersion, forKey: .sdkVersion)
        try container.encode(threadName, forKey: .threadName)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(functionName, forKey: .functionName)
        try container.encode(lineNumber, forKey: .lineNumber)
    }
}
