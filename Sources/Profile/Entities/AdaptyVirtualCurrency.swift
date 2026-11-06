//
//  AdaptyVirtualCurrency.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.09.2022.


import Foundation

public struct AdaptyVirtualCurrency: RawRepresentable, Hashable, Sendable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(rawValue: String) {
        self.init(rawValue)
    }

    public static let Coins = AdaptyVirtualCurrency("COINS")
    public static let Gems = AdaptyVirtualCurrency("GEMS")
}

extension AdaptyVirtualCurrency: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension AdaptyVirtualCurrency: Codable {}
