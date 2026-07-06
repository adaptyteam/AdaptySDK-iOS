//
//  AdaptyTransactionOfferType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.07.2026.
//

import Foundation
import StoreKit

public struct AdaptyTransactionOfferType: Sendable, RawRepresentable, Equatable, Hashable {
    public let rawValue: Int

    @inlinable
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let introductory = AdaptyTransactionOfferType(rawValue: 1)
    public static let promotional = AdaptyTransactionOfferType(rawValue: 2)
    public static let code = AdaptyTransactionOfferType(rawValue: 3)
    public static let winBack = AdaptyTransactionOfferType(rawValue: 4)
}

extension AdaptyTransactionOfferType {
    static let introductoryKey = "introductory"
    static let promotionalKey = "promotional"
    static let codeKey = "code"
    static let winBackKey = "win_back"
    static let unknownPrefix = "sk_"

    init?(stringValue: String) {
        switch stringValue {
        case Self.introductoryKey: self = .introductory
        case Self.promotionalKey: self = .promotional
        case Self.codeKey: self = .code
        case Self.winBackKey: self = .winBack
        default:
            guard stringValue.hasPrefix(Self.unknownPrefix),
                  let intvalue = Int(stringValue.dropFirst(Self.unknownPrefix.count))
            else { return nil }
            self = .init(rawValue: intvalue)
        }
    }

    var stringValue: String {
        switch self {
        case .introductory: Self.introductoryKey
        case .promotional: Self.promotionalKey
        case .code: Self.codeKey
        case .winBack: Self.winBackKey
        default: Self.unknownPrefix + String(rawValue)
        }
    }
}

extension AdaptyTransactionOfferType: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if let value = Self(stringValue: stringValue) {
            self = value
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid AdaptyTransactionOfferType value: \(stringValue)")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}
