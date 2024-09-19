//
//  Price.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 18.09.2024
//

import Foundation

struct Price: Sendable, Hashable {
    let amount: Decimal
    let currencyCode: String?
    let currencySymbol: String?
    let localizedString: String?
}

extension Price: CustomStringConvertible {
    public var description: String {
        "(\(amount)"
            + (currencyCode.map { ", code: \($0)" } ?? "")
            + (currencySymbol.map { ", symbol: \($0)" } ?? "")
            + (localizedString.map { ", localized: \($0)" } ?? "")
            + ")"
    }
}

extension Price: Encodable {
    enum CodingKeys: String, CodingKey {
        case amount
        case currencyCode = "currency_code"
        case currencySymbol = "currency_symbol"
        case localizedString = "localized_string"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encodeIfPresent(currencyCode, forKey: .currencyCode)
        try container.encodeIfPresent(currencySymbol, forKey: .currencySymbol)
        try container.encodeIfPresent(localizedString, forKey: .localizedString)
    }
}
