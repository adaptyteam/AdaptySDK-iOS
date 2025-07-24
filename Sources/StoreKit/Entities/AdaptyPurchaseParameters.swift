//
//  AdaptyPurchaseParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.07.2025.
//

import Foundation

public struct AdaptyPurchaseParameters: Sendable, Hashable {
    public let appAccountToken: UUID?

    public init(appAccountToken: UUID?) {
        self.appAccountToken = appAccountToken
    }
}
