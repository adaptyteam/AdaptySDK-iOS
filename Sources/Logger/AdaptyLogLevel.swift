//
//  AdaptyLogLevel.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.10.2022.
//

import Foundation

public enum AdaptyLogLevel: Int {
    /// Only errors will be logged
    case error
    /// `.error` +  messages from the SDK that do not cause critical errors, but are worth paying attention to
    case warn
    /// `.warn` +  information messages, such as those that log the lifecycle of various modules
    case info
    /// `.info` + any additional information that may be useful during debugging, such as function calls, API queries, etc.
    case verbose
    /// Debug purposes logging level
    case debug
}

extension Adapty {
    /// Set to the most appropriate level of logging
    public static var logLevel: AdaptyLogLevel {
        get { AdaptyLogger.logLevel }
        set { AdaptyLogger.logLevel = newValue }
    }
}

extension AdaptyLogLevel: Codable {
    enum CodingValues: String {
        case error
        case warn
        case info
        case verbose
        case debug
    }

    public init?(rawStringValue: String) {
        guard let value = CodingValues(rawValue: rawStringValue) else { return nil }
        switch value {
        case .error: self = .error
        case .warn: self = .warn
        case .info: self = .info
        case .verbose: self = .verbose
        case .debug: self = .debug
        }
    }

    public var rawStringValue: String {
        let value: CodingValues =
            switch self {
            case .error: .error
            case .warn: .warn
            case .info: .info
            case .verbose: .verbose
            case .debug: .debug
            }
        return value.rawValue
    }

    public init(from decoder: Decoder) throws {
        guard let value = try AdaptyLogLevel(rawStringValue: decoder.singleValueContainer().decode(String.self)) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "unknown value"))
        }
        self = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawStringValue)
    }
}

extension AdaptyLogLevel: CustomStringConvertible {
    public var description: String { rawStringValue.uppercased() }
}
