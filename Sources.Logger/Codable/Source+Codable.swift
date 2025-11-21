//
//  Source+Codable.swift
//  AdaptyLogger
//
//  Created by Aleksei Valiano on 24.08.2024
//

import Foundation

extension AdaptyLogger.Source: Codable {
    enum CodingKeys: String, CodingKey {
        case fileName = "file"
        case functionName = "function"
        case lineNumber = "line"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fileName = try container.decode(String.self, forKey: .fileName)
        functionName = try container.decode(String.self, forKey: .functionName)
        lineNumber = try container.decode(UInt.self, forKey: .lineNumber)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(functionName, forKey: .functionName)
        try container.encode(lineNumber, forKey: .lineNumber)
    }
}
