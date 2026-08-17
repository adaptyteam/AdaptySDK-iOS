//
//  AdaptyConfiguration.StoreMessagesHandling.swift
//  AdaptySDK
//

public extension AdaptyConfiguration {
    /// Controls whether StoreKit or the application owns the presentation timing of App Store messages.
    enum StoreMessagesHandling: Sendable {
        /// The default mode. Adapty does not subscribe to StoreKit messages.
        public static let `default` = StoreMessagesHandling.auto

        /// Leaves automatic message presentation under StoreKit control.
        case auto

        /// Captures StoreKit messages so the application can choose when to display them.
        case manual
    }
}

extension AdaptyConfiguration.StoreMessagesHandling: CustomStringConvertible {
    var rawValue: String {
        switch self {
        case .auto:
            "auto"
        case .manual:
            "manual"
        }
    }

    public var description: String {
        rawValue
    }
}

extension AdaptyConfiguration.StoreMessagesHandling: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "auto":
            self = .auto
        case "manual":
            self = .manual
        case "default":
            self = .default
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown value: \(value)")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
