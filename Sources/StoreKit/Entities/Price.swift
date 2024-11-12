//
//  Price.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 18.09.2024
//

import Foundation

package struct Price: Sendable, Hashable {
    package let amount: Decimal
    package let currencyCode: String?
    package let currencySymbol: String?
    package let localizedString: String?
    
    package init(amount: Decimal, currencyCode: String?, currencySymbol: String?, localizedString: String?) {
        self.amount = amount
        self.currencyCode = currencyCode
        self.currencySymbol = currencySymbol
        self.localizedString = localizedString
    }
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
