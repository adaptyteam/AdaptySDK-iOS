//
//  AdaptyPurchaseParameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.07.2025.
//

import Foundation

public struct AdaptyPurchaseParameters: Sendable, Hashable {
    public static let `default` = AdaptyPurchaseParameters()

    public enum AppAccountTokenValue: Sendable, Hashable {
        public static let `default` = Self.customerUserId
        case none
        case customerUserId
        case other(UUID)
    }

    public let appAccountToken: AppAccountTokenValue

    public init(appAccountToken: AppAccountTokenValue = .default) {
        self.appAccountToken = appAccountToken
    }
}

extension AdaptyPurchaseParameters.AppAccountTokenValue: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none:
            ".none"
        case .customerUserId:
            ".customerUserId"
        case .other(let uuid):
            ".other(\(uuid))"
        }
    }
}

extension AdaptyPurchaseParameters.AppAccountTokenValue {
    func asUUID(customerUserId: String?) -> UUID? {
        switch self {
        case .none:
            return nil
        case .customerUserId:
            guard let customerUserId, let uuid = UUID(uuidString: customerUserId) else {
                return nil
            }
            return uuid
        case .other(let uuid):
            return uuid
        }
    }
}
