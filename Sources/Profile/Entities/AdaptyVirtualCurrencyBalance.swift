//
//  AdaptyVirtualCurrencyBalance.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.09.2022.

import Foundation

/// The balance of a virtual currency
public struct AdaptyVirtualCurrencyBalance: Sendable, Hashable {
    /// The amount of currency
    public let available: UInt

    public init(available: UInt) {
        self.available = available
    }
}

extension AdaptyVirtualCurrencyBalance: Codable {
    enum CodingKeys: CodingKey {
        case available
    }
}
