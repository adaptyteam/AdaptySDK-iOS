//
//  AdaptyPurchaseResult+Encodable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 12.11.2024.
//

import Adapty
import Foundation

extension AdaptyPurchaseResult: Encodable {
    private enum CodingKeys: String, CodingKey {
        case resultType = "type"
        case profile
        case jwsTransaction = "jws_transaction"
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .pending:
            try container.encode("pending", forKey: .resultType)
        case .userCancelled:
            try container.encode("user_cancelled", forKey: .resultType)
        case .success(let profile, _):
            try container.encode("success", forKey: .resultType)
            try container.encode(profile, forKey: .profile)
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                try container.encodeIfPresent(jwsTransaction, forKey: .jwsTransaction)
            }
        }
    }

    @inlinable
    public var asAdaptyJsonData: AdaptyJsonData {
        get throws {
            try AdaptyPlugin.encoder.encode(self)
        }
    }
}
