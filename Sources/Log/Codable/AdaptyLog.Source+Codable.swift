//
//  AdaptyLog.Source+Codable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.08.2024
//

import Foundation

extension AdaptyLog.Source: Codable {
    enum CodingKeys: String, CodingKey {
        case threadName = "thread"
        case fileName = "file"
        case functionName = "function"
        case lineNumber = "line"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        threadName = try container.decode(String.self, forKey: .threadName)
        fileName = try container.decode(String.self, forKey: .fileName)
        functionName = try container.decode(String.self, forKey: .functionName)
        lineNumber = try container.decode(UInt.self, forKey: .lineNumber)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(threadName, forKey: .threadName)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(functionName, forKey: .functionName)
        try container.encode(lineNumber, forKey: .lineNumber)
    }
}
